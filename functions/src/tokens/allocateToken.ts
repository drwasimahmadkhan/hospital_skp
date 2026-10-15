import { FieldValue } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../utils/admin";
import { requireAuth } from "../utils/auth";
import { writeAuditLog } from "../utils/audit";
import {
  APPOINTMENT_STATUS,
  assertDateYmd,
  COLLECTIONS,
  dailyCounterId,
  DEFAULT_MAX_TOKENS_PER_DAY,
  doctorDayQueueId,
  QUEUE_STATUS,
  ROLES,
  TOKEN,
} from "../utils/constants";

export interface AllocateTokenRequest {
  doctorId: string;
  patientId: string;
  appointmentDate: string; // YYYY-MM-DD Asia/Karachi
  departmentId?: string;
  familyMemberId?: string | null;
  chiefComplaint?: string;
  locale?: "en" | "ur";
}

export interface AllocateTokenResponse {
  appointmentId: string;
  tokenNumber: number;
  tokenDisplay: string;
  status: string;
}

export const allocateToken = onCall(
  { region: "asia-south1", maxInstances: 20 },
  async (request): Promise<AllocateTokenResponse> => {
    const user = await requireAuth(request);
    const data = request.data as AllocateTokenRequest;

    if (!data?.doctorId || !data?.patientId || !data?.appointmentDate) {
      throw new HttpsError("invalid-argument", "doctorId, patientId, appointmentDate required.");
    }
    assertDateYmd(data.appointmentDate);

    const patientSnap = await db.collection(COLLECTIONS.PATIENTS).doc(data.patientId).get();
    if (!patientSnap.exists) {
      throw new HttpsError("not-found", "Patient not found.");
    }
    const patient = patientSnap.data()!;
    if (user.role === ROLES.PATIENT && patient.userId !== user.uid) {
      throw new HttpsError("permission-denied", "Cannot book for another user.");
    }

    const doctorSnap = await db.collection(COLLECTIONS.DOCTORS).doc(data.doctorId).get();
    if (!doctorSnap.exists || doctorSnap.data()?.isActive === false) {
      throw new HttpsError("failed-precondition", "Doctor not available.");
    }

    const counterRef = db
      .collection(COLLECTIONS.DAILY_TOKEN_COUNTERS)
      .doc(dailyCounterId(data.doctorId, data.appointmentDate));
    const queueRef = db
      .collection(COLLECTIONS.QUEUE_STATE)
      .doc(doctorDayQueueId(data.doctorId, data.appointmentDate));

    const appointmentRef = db.collection(COLLECTIONS.APPOINTMENTS).doc();

    const result = await db.runTransaction(async (tx) => {
      const duplicateQuery = db
        .collection(COLLECTIONS.APPOINTMENTS)
        .where("doctorId", "==", data.doctorId)
        .where("appointmentDate", "==", data.appointmentDate)
        .where("patientId", "==", data.patientId)
        .where("status", "in", [
          APPOINTMENT_STATUS.BOOKED,
          APPOINTMENT_STATUS.CHECKED_IN,
          APPOINTMENT_STATUS.IN_QUEUE,
          APPOINTMENT_STATUS.CALLED,
          APPOINTMENT_STATUS.IN_CONSULTATION,
        ])
        .limit(1);

      const dupSnap = await tx.get(duplicateQuery);
      if (!dupSnap.empty) {
        throw new HttpsError(
          "already-exists",
          "Patient already has an active appointment with this doctor today."
        );
      }

      const scheduleSnap = await tx.get(
        db
          .collection(COLLECTIONS.DOCTOR_SCHEDULES)
          .where("doctorId", "==", data.doctorId)
          .where("isActive", "==", true)
          .limit(1)
      );
      let maxTokens = DEFAULT_MAX_TOKENS_PER_DAY;
      if (!scheduleSnap.empty) {
        maxTokens = scheduleSnap.docs[0].data().maxTokensPerDay ?? maxTokens;
      }

      const counterSnap = await tx.get(counterRef);
      let nextToken = 1;
      if (counterSnap.exists) {
        nextToken = (counterSnap.data()?.lastTokenNumber ?? 0) + 1;
      }
      if (nextToken > maxTokens) {
        throw new HttpsError(
          "resource-exhausted",
          "No tokens remaining for this doctor today."
        );
      }

      const tokenDisplay = TOKEN.formatDisplay(nextToken);
      const now = FieldValue.serverTimestamp();

      tx.set(counterRef, {
        doctorId: data.doctorId,
        appointmentDate: data.appointmentDate,
        lastTokenNumber: nextToken,
        maxTokens,
        updatedAt: now,
      }, { merge: true });

      const appointment = {
        doctorId: data.doctorId,
        departmentId: data.departmentId ?? doctorSnap.data()?.departmentId ?? null,
        patientId: data.patientId,
        patientUserId: patient.userId,
        familyMemberId: data.familyMemberId ?? null,
        appointmentDate: data.appointmentDate,
        tokenNumber: nextToken,
        tokenDisplay,
        status: APPOINTMENT_STATUS.BOOKED,
        chiefComplaint: data.chiefComplaint ?? "",
        locale: data.locale ?? "en",
        bookedByUid: user.uid,
        checkedInAt: null,
        calledAt: null,
        completedAt: null,
        createdAt: now,
        updatedAt: now,
      };

      tx.set(appointmentRef, appointment);

      const queueSnap = await tx.get(queueRef);
      if (!queueSnap.exists) {
        tx.set(queueRef, {
          doctorId: data.doctorId,
          appointmentDate: data.appointmentDate,
          status: QUEUE_STATUS.OPEN,
          currentTokenNumber: 0,
          currentAppointmentId: null,
          lastCalledToken: 0,
          pausedAt: null,
          pausedReason: null,
          totalBooked: 1,
          totalCompleted: 0,
          updatedAt: now,
        });
      } else {
        tx.update(queueRef, {
          totalBooked: FieldValue.increment(1),
          updatedAt: now,
        });
      }

      return {
        appointmentId: appointmentRef.id,
        tokenNumber: nextToken,
        tokenDisplay,
        status: APPOINTMENT_STATUS.BOOKED,
      };
    });

    await writeAuditLog({
      action: "TOKEN_ALLOCATED",
      actorUid: user.uid,
      actorRole: user.role,
      targetType: "appointment",
      targetId: result.appointmentId,
      metadata: {
        doctorId: data.doctorId,
        tokenDisplay: result.tokenDisplay,
        appointmentDate: data.appointmentDate,
      },
    });

    return result;
  }
);
