import { FieldValue } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../utils/admin";
import { requireAuth, requireDoctorForQueue } from "../utils/auth";
import { writeAuditLog } from "../utils/audit";
import { createNotification } from "../utils/notify";
import {
  APPOINTMENT_STATUS,
  assertDateYmd,
  COLLECTIONS,
  doctorDayQueueId,
  NOTIFICATION_TYPE,
  QUEUE_STATUS,
} from "../utils/constants";

export interface CallNextRequest {
  doctorId: string;
  appointmentDate: string;
}

export interface CallNextResponse {
  appointmentId: string | null;
  tokenDisplay: string | null;
  status: string;
  message: string;
}

export const callNext = onCall(
  { region: "asia-south1" },
  async (request): Promise<CallNextResponse> => {
    const user = await requireAuth(request);
    const data = request.data as CallNextRequest;

    if (!data?.doctorId || !data?.appointmentDate) {
      throw new HttpsError("invalid-argument", "doctorId and appointmentDate required.");
    }
    assertDateYmd(data.appointmentDate);
    requireDoctorForQueue(user, data.doctorId);

    const queueRef = db
      .collection(COLLECTIONS.QUEUE_STATE)
      .doc(doctorDayQueueId(data.doctorId, data.appointmentDate));

    const result = await db.runTransaction(async (tx) => {
      const queueSnap = await tx.get(queueRef);
      if (!queueSnap.exists) {
        throw new HttpsError("not-found", "Queue not initialized for this day.");
      }
      const queue = queueSnap.data()!;
      if (queue.status === QUEUE_STATUS.PAUSED) {
        throw new HttpsError("failed-precondition", "Queue is paused.");
      }
      if (queue.status === QUEUE_STATUS.CLOSED) {
        throw new HttpsError("failed-precondition", "Queue is closed.");
      }

      const currentId = queue.currentAppointmentId as string | null;
      if (currentId) {
        const currentSnap = await tx.get(
          db.collection(COLLECTIONS.APPOINTMENTS).doc(currentId)
        );
        if (currentSnap.exists) {
          const st = currentSnap.data()!.status;
          if (
            st === APPOINTMENT_STATUS.CALLED ||
            st === APPOINTMENT_STATUS.IN_CONSULTATION
          ) {
            throw new HttpsError(
              "failed-precondition",
              "Complete or skip current patient before calling next."
            );
          }
        }
      }

      const nextQuery = db
        .collection(COLLECTIONS.APPOINTMENTS)
        .where("doctorId", "==", data.doctorId)
        .where("appointmentDate", "==", data.appointmentDate)
        .where("status", "in", [
          APPOINTMENT_STATUS.CHECKED_IN,
          APPOINTMENT_STATUS.IN_QUEUE,
          APPOINTMENT_STATUS.BOOKED,
        ])
        .orderBy("tokenNumber", "asc")
        .limit(1);

      const nextSnap = await tx.get(nextQuery);
      if (nextSnap.empty) {
        return {
          appointmentId: null,
          tokenDisplay: null,
          status: "EMPTY",
          message: "No patients waiting in queue.",
          notifyUserId: null as string | null,
          tokenDisplayNotify: null as string | null,
          appointmentIdNotify: null as string | null,
        };
      }

      const doc = nextSnap.docs[0];
      const appt = doc.data();
      const now = FieldValue.serverTimestamp();

      tx.update(doc.ref, {
        status: APPOINTMENT_STATUS.CALLED,
        calledAt: now,
        updatedAt: now,
      });

      tx.update(queueRef, {
        currentAppointmentId: doc.id,
        currentTokenNumber: appt.tokenNumber,
        lastCalledToken: appt.tokenNumber,
        updatedAt: now,
      });

      return {
        appointmentId: doc.id,
        tokenDisplay: appt.tokenDisplay as string,
        status: APPOINTMENT_STATUS.CALLED,
        message: "Patient called.",
        notifyUserId: appt.patientUserId as string,
        tokenDisplayNotify: appt.tokenDisplay as string,
        appointmentIdNotify: doc.id,
      };
    });

    if (result.notifyUserId) {
      await createNotification({
        userId: result.notifyUserId,
        type: NOTIFICATION_TYPE.YOUR_TURN,
        titleEn: "Your turn",
        titleUr: "آپ ki باری",
        bodyEn: `Please proceed to the consultation room. Token ${result.tokenDisplayNotify}.`,
        bodyUr: `براہِ کرم کنسلٹیشن روم میں آئیں۔ ٹوکن ${result.tokenDisplayNotify}۔`,
        appointmentId: result.appointmentIdNotify ?? undefined,
        doctorId: data.doctorId,
      });
    }

    await writeAuditLog({
      action: "QUEUE_CALL_NEXT",
      actorUid: user.uid,
      actorRole: user.role,
      targetType: "queue_state",
      targetId: doctorDayQueueId(data.doctorId, data.appointmentDate),
      metadata: { appointmentId: result.appointmentId, token: result.tokenDisplay },
    });

    return {
      appointmentId: result.appointmentId,
      tokenDisplay: result.tokenDisplay,
      status: result.status,
      message: result.message,
    };
  }
);
