import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "../utils/admin";
import { createNotification } from "../utils/notify";
import {
  APPOINTMENT_STATUS,
  COLLECTIONS,
  NOTIFICATION_TYPE,
  QUEUE_NEAR_THRESHOLD,
  QUEUE_STATUS,
} from "../utils/constants";

/** After appointment created (post allocateToken), send booking confirmation. */
export const onAppointmentCreated = onDocumentCreated(
  {
    document: `${COLLECTIONS.APPOINTMENTS}/{appointmentId}`,
    region: "asia-south1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const appt = snap.data();
    if (!appt.patientUserId) return;

    await createNotification({
      userId: appt.patientUserId,
      type: NOTIFICATION_TYPE.BOOKING_CONFIRMED,
      titleEn: "Appointment confirmed",
      titleUr: "اپائنٹمنٹ confirm",
      bodyEn: `Token ${appt.tokenDisplay} with Dr. on ${appt.appointmentDate}. Please arrive 15 minutes early.`,
      bodyUr: `ٹوکن ${appt.tokenDisplay}، تاریخ ${appt.appointmentDate}۔ 15 منٹ پہلے پہنچیں۔`,
      appointmentId: snap.id,
      doctorId: appt.doctorId,
    });
  }
);

/** When queue advances, notify patients ~3 tokens ahead. */
export const onQueueStateUpdated = onDocumentUpdated(
  {
    document: `${COLLECTIONS.QUEUE_STATE}/{queueId}`,
    region: "asia-south1",
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const prevToken = before.lastCalledToken ?? 0;
    const currToken = after.lastCalledToken ?? 0;
    if (currToken <= prevToken) return;

    const doctorId = after.doctorId as string;
    const appointmentDate = after.appointmentDate as string;
    const targetMin = currToken + 1;
    const targetMax = currToken + QUEUE_NEAR_THRESHOLD;

    const waiting = await db
      .collection(COLLECTIONS.APPOINTMENTS)
      .where("doctorId", "==", doctorId)
      .where("appointmentDate", "==", appointmentDate)
      .where("tokenNumber", ">=", targetMin)
      .where("tokenNumber", "<=", targetMax)
      .where("status", "in", [
        APPOINTMENT_STATUS.BOOKED,
        APPOINTMENT_STATUS.CHECKED_IN,
        APPOINTMENT_STATUS.IN_QUEUE,
      ])
      .get();

    for (const doc of waiting.docs) {
      const appt = doc.data();
      if (!appt.patientUserId) continue;
      const ahead = Math.floor(appt.tokenNumber - currToken);
      await createNotification({
        userId: appt.patientUserId,
        type: NOTIFICATION_TYPE.QUEUE_NEAR,
        titleEn: "Queue update",
        titleUr: "قطار ki update",
        bodyEn: `You are about ${ahead} patient(s) away. Token ${appt.tokenDisplay}.`,
        bodyUr: `آپ تقریباً ${ahead} مریض دور ہیں۔ ٹوکن ${appt.tokenDisplay}۔`,
        appointmentId: doc.id,
        doctorId,
      });
    }
  }
);

/** Doctor pause → notify currently called + next few in queue. */
export const onDoctorQueuePaused = onDocumentUpdated(
  {
    document: `${COLLECTIONS.QUEUE_STATE}/{queueId}`,
    region: "asia-south1",
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;
    if (after.status !== QUEUE_STATUS.PAUSED) return;

    const doctorId = after.doctorId as string;
    const appointmentDate = after.appointmentDate as string;
    const reason = (after.pausedReason as string) ?? "Doctor on break";

    const active = await db
      .collection(COLLECTIONS.APPOINTMENTS)
      .where("doctorId", "==", doctorId)
      .where("appointmentDate", "==", appointmentDate)
      .where("status", "in", [
        APPOINTMENT_STATUS.CALLED,
        APPOINTMENT_STATUS.CHECKED_IN,
        APPOINTMENT_STATUS.IN_QUEUE,
        APPOINTMENT_STATUS.BOOKED,
      ])
      .orderBy("tokenNumber")
      .limit(10)
      .get();

    for (const doc of active.docs) {
      const appt = doc.data();
      if (!appt.patientUserId) continue;
      await createNotification({
        userId: appt.patientUserId,
        type: NOTIFICATION_TYPE.DOCTOR_LEAVE,
        titleEn: "Doctor temporarily unavailable",
        titleUr: "ڈاکٹر عارضی طور پر دستیاب نہیں",
        bodyEn: `${reason}. Queue will resume shortly.`,
        bodyUr: `${reason}۔ قطار جلد دوبارہ شروع ہوگی۔`,
        appointmentId: doc.id,
        doctorId,
      });
    }

    await db.collection(COLLECTIONS.AUDIT_LOGS).add({
      action: "DOCTOR_LEAVE_NOTIFIED",
      targetType: "queue_state",
      targetId: event.params.queueId,
      metadata: { reason, notifiedCount: active.size },
      createdAt: FieldValue.serverTimestamp(),
    });
  }
);
