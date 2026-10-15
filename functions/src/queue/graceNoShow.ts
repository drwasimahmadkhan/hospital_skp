import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onCall } from "firebase-functions/v2/https";
import { db } from "../utils/admin";
import { requireAuth, requireRoles } from "../utils/auth";
import { createNotification } from "../utils/notify";
import {
  APPOINTMENT_STATUS,
  COLLECTIONS,
  GRACE_NO_SHOW_MINUTES,
  NOTIFICATION_TYPE,
  ROLES,
} from "../utils/constants";

/** Runs every 5 minutes — marks CALLED appointments as NO_SHOW after grace period. */
export const graceNoShowScheduled = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "Asia/Karachi",
    region: "asia-south1",
  },
  async () => {
    await processGraceNoShows();
  }
);

/** Manual trigger for reception/admin (same logic as scheduler). */
export const graceNoShowManual = onCall(
  { region: "asia-south1" },
  async (request) => {
    const user = await requireAuth(request);
    requireRoles(user, [ROLES.ADMIN, ROLES.RECEPTIONIST]);
    const count = await processGraceNoShows();
    return { processed: count };
  }
);

async function processGraceNoShows(): Promise<number> {
  const cutoff = Timestamp.fromDate(
    new Date(Date.now() - GRACE_NO_SHOW_MINUTES * 60 * 1000)
  );

  const snap = await db
    .collection(COLLECTIONS.APPOINTMENTS)
    .where("status", "==", APPOINTMENT_STATUS.CALLED)
    .where("calledAt", "<=", cutoff)
    .limit(50)
    .get();

  let processed = 0;
  for (const doc of snap.docs) {
    const appt = doc.data();
    const now = FieldValue.serverTimestamp();
    await doc.ref.update({
      status: APPOINTMENT_STATUS.NO_SHOW,
      updatedAt: now,
    });

    if (appt.patientUserId) {
      await createNotification({
        userId: appt.patientUserId,
        type: NOTIFICATION_TYPE.NO_SHOW_WARNING,
        titleEn: "Missed call",
        titleUr: "کال miss ہو گئی",
        bodyEn: `Token ${appt.tokenDisplay} was marked no-show after ${GRACE_NO_SHOW_MINUTES} minutes.`,
        bodyUr: `ٹوکن ${appt.tokenDisplay} کو ${GRACE_NO_SHOW_MINUTES} منٹ بعد no-show قرار دیا گیا۔`,
        appointmentId: doc.id,
        doctorId: appt.doctorId,
      });
    }
    processed += 1;
  }
  return processed;
}
