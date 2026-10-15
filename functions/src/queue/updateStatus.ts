import { DocumentReference, FieldValue } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../utils/admin";
import { requireAuth, requireDoctorForQueue } from "../utils/auth";
import { writeAuditLog } from "../utils/audit";
import {
  APPOINTMENT_STATUS,
  assertDateYmd,
  COLLECTIONS,
  doctorDayQueueId,
  QUEUE_STATUS,
  ROLES,
  TOKEN,
} from "../utils/constants";

export type QueueAction =
  | "check_in"
  | "complete"
  | "skip"
  | "no_show"
  | "pause"
  | "resume"
  | "emergency_insert"
  | "start_consultation";

export interface UpdateQueueStatusRequest {
  action: QueueAction;
  doctorId: string;
  appointmentDate: string;
  appointmentId?: string;
  pauseReason?: string;
  /** emergency_insert: optional patient; creates front-of-queue token */
  emergencyPatientId?: string;
  emergencyChiefComplaint?: string;
}

export interface UpdateQueueStatusResponse {
  success: boolean;
  appointmentId?: string;
  tokenDisplay?: string;
  queueStatus?: string;
}

export const updateQueueStatus = onCall(
  { region: "asia-south1" },
  async (request): Promise<UpdateQueueStatusResponse> => {
    const user = await requireAuth(request);
    const data = request.data as UpdateQueueStatusRequest;

    if (!data?.action || !data?.doctorId || !data?.appointmentDate) {
      throw new HttpsError("invalid-argument", "action, doctorId, appointmentDate required.");
    }
    assertDateYmd(data.appointmentDate);

    const queueRef = db
      .collection(COLLECTIONS.QUEUE_STATE)
      .doc(doctorDayQueueId(data.doctorId, data.appointmentDate));

    switch (data.action) {
      case "check_in":
        return checkIn(user.uid, user.role, data);
      case "complete":
      case "skip":
      case "no_show":
      case "start_consultation":
        requireDoctorForQueue(user, data.doctorId);
        return staffUpdateAppointment(user, data);
      case "pause":
      case "resume":
        requireDoctorForQueue(user, data.doctorId);
        return pauseResume(user, data, queueRef);
      case "emergency_insert":
        requireDoctorForQueue(user, data.doctorId);
        return emergencyInsert(user, data, queueRef);
      default:
        throw new HttpsError("invalid-argument", "Unknown action.");
    }
  }
);

async function checkIn(
  uid: string,
  role: string,
  data: UpdateQueueStatusRequest
): Promise<UpdateQueueStatusResponse> {
  if (!data.appointmentId) {
    throw new HttpsError("invalid-argument", "appointmentId required for check_in.");
  }
  const apptRef = db.collection(COLLECTIONS.APPOINTMENTS).doc(data.appointmentId);
  const apptSnap = await apptRef.get();
  if (!apptSnap.exists) throw new HttpsError("not-found", "Appointment not found.");
  const appt = apptSnap.data()!;

  if (role === ROLES.PATIENT && appt.patientUserId !== uid) {
    throw new HttpsError("permission-denied", "Not your appointment.");
  }
  if (appt.status !== APPOINTMENT_STATUS.BOOKED) {
    throw new HttpsError("failed-precondition", "Only BOOKED appointments can check in.");
  }

  const now = FieldValue.serverTimestamp();
  await apptRef.update({
    status: APPOINTMENT_STATUS.CHECKED_IN,
    checkedInAt: now,
    updatedAt: now,
  });

  await writeAuditLog({
    action: "APPOINTMENT_CHECK_IN",
    actorUid: uid,
    actorRole: role,
    targetType: "appointment",
    targetId: data.appointmentId,
  });

  return { success: true, appointmentId: data.appointmentId, tokenDisplay: appt.tokenDisplay };
}

async function staffUpdateAppointment(
  user: { uid: string; role: string },
  data: UpdateQueueStatusRequest
): Promise<UpdateQueueStatusResponse> {
  if (!data.appointmentId) {
    throw new HttpsError("invalid-argument", "appointmentId required.");
  }

  const apptRef = db.collection(COLLECTIONS.APPOINTMENTS).doc(data.appointmentId);
  const queueRef = db
    .collection(COLLECTIONS.QUEUE_STATE)
    .doc(doctorDayQueueId(data.doctorId, data.appointmentDate));

  const statusMap: Record<string, string> = {
    complete: APPOINTMENT_STATUS.COMPLETED,
    skip: APPOINTMENT_STATUS.SKIPPED,
    no_show: APPOINTMENT_STATUS.NO_SHOW,
    start_consultation: APPOINTMENT_STATUS.IN_CONSULTATION,
  };

  const newStatus = statusMap[data.action];
  if (!newStatus) throw new HttpsError("invalid-argument", "Invalid staff action.");

  await db.runTransaction(async (tx) => {
    const apptSnap = await tx.get(apptRef);
    if (!apptSnap.exists) throw new HttpsError("not-found", "Appointment not found.");
    const now = FieldValue.serverTimestamp();
    const updates: Record<string, unknown> = {
      status: newStatus,
      updatedAt: now,
    };
    if (data.action === "complete") updates.completedAt = now;

    tx.update(apptRef, updates);

    const queueSnap = await tx.get(queueRef);
    if (queueSnap.exists && queueSnap.data()?.currentAppointmentId === data.appointmentId) {
      const qUpdates: Record<string, unknown> = {
        currentAppointmentId: null,
        updatedAt: now,
      };
      if (data.action === "complete") {
        qUpdates.totalCompleted = FieldValue.increment(1);
      }
      tx.update(queueRef, qUpdates);
    }
  });

  await writeAuditLog({
    action: `APPOINTMENT_${data.action.toUpperCase()}`,
    actorUid: user.uid,
    actorRole: user.role,
    targetType: "appointment",
    targetId: data.appointmentId,
  });

  return { success: true, appointmentId: data.appointmentId };
}

async function pauseResume(
  user: { uid: string; role: string },
  data: UpdateQueueStatusRequest,
  queueRef: DocumentReference
): Promise<UpdateQueueStatusResponse> {
  const now = FieldValue.serverTimestamp();
  if (data.action === "pause") {
    await queueRef.update({
      status: QUEUE_STATUS.PAUSED,
      pausedAt: now,
      pausedReason: data.pauseReason ?? "Break",
      updatedAt: now,
    });
  } else {
    await queueRef.update({
      status: QUEUE_STATUS.OPEN,
      pausedAt: null,
      pausedReason: null,
      updatedAt: now,
    });
  }

  await writeAuditLog({
    action: data.action === "pause" ? "QUEUE_PAUSED" : "QUEUE_RESUMED",
    actorUid: user.uid,
    actorRole: user.role,
    targetType: "queue_state",
    targetId: queueRef.id,
  });

  const snap = await queueRef.get();
  return { success: true, queueStatus: snap.data()?.status };
}

async function emergencyInsert(
  user: { uid: string; role: string },
  data: UpdateQueueStatusRequest,
  queueRef: DocumentReference
): Promise<UpdateQueueStatusResponse> {
  if (!data.emergencyPatientId) {
    throw new HttpsError("invalid-argument", "emergencyPatientId required.");
  }

  const patientSnap = await db
    .collection(COLLECTIONS.PATIENTS)
    .doc(data.emergencyPatientId)
    .get();
  if (!patientSnap.exists) throw new HttpsError("not-found", "Patient not found.");

  const appointmentRef = db.collection(COLLECTIONS.APPOINTMENTS).doc();
  let tokenDisplay = "";

  await db.runTransaction(async (tx) => {
    const queueSnap = await tx.get(queueRef);
    const lastCalled = queueSnap.exists
      ? (queueSnap.data()?.lastCalledToken ?? 0)
      : 0;
    const emergencyToken = Math.max(0, lastCalled) + 0.5;
    const displayNum = Math.ceil(emergencyToken);
    tokenDisplay = `${TOKEN.prefix}-E${String(displayNum).padStart(2, "0")}`;
    const now = FieldValue.serverTimestamp();
    const patient = patientSnap.data()!;

    tx.set(appointmentRef, {
      doctorId: data.doctorId,
      patientId: data.emergencyPatientId,
      patientUserId: patient.userId,
      appointmentDate: data.appointmentDate,
      tokenNumber: emergencyToken,
      tokenDisplay,
      status: APPOINTMENT_STATUS.IN_QUEUE,
      isEmergency: true,
      chiefComplaint: data.emergencyChiefComplaint ?? "Emergency",
      bookedByUid: user.uid,
      checkedInAt: now,
      createdAt: now,
      updatedAt: now,
    });

    if (queueSnap.exists) {
      tx.update(queueRef, {
        totalBooked: FieldValue.increment(1),
        updatedAt: now,
      });
    }
  });

  await writeAuditLog({
    action: "EMERGENCY_INSERT",
    actorUid: user.uid,
    actorRole: user.role,
    targetType: "appointment",
    targetId: appointmentRef.id,
  });

  return {
    success: true,
    appointmentId: appointmentRef.id,
    tokenDisplay,
  };
}
