import { Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db } from "../utils/admin";
import { createNotification } from "../utils/notify";
import {
  APPOINTMENT_STATUS,
  COLLECTIONS,
  HOSPITAL,
  NOTIFICATION_TYPE,
} from "../utils/constants";

function ymdInKarachi(date: Date): string {
  return date.toLocaleDateString("en-CA", { timeZone: HOSPITAL.timezone });
}

function hourBucketInKarachi(date: Date): number {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: HOSPITAL.timezone,
    hour: "numeric",
    hour12: false,
  }).formatToParts(date);
  return Number(parts.find((p) => p.type === "hour")?.value ?? 0);
}

/** Daily at 09:00 PKT — reminders for tomorrow's appointments. */
export const reminderOneDayBefore = onSchedule(
  {
    schedule: "0 9 * * *",
    timeZone: "Asia/Karachi",
    region: "asia-south1",
  },
  async () => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const dateYmd = ymdInKarachi(tomorrow);

    await sendRemindersForDate(dateYmd, NOTIFICATION_TYPE.REMINDER_1_DAY, {
      titleEn: "Appointment tomorrow",
      titleUr: "کل appointment",
      bodyEn: (token: string, date: string) =>
        `Reminder: Token ${token} on ${date}.`,
      bodyUr: (token: string, date: string) =>
        `یاد دہانی: ٹوکن ${token}، تاریخ ${date}۔`,
    });
  }
);

/** Hourly — appointments today in the next hour window (simplified: same-day, morning run). */
export const reminderOneHourBefore = onSchedule(
  {
    schedule: "0 * * * *",
    timeZone: "Asia/Karachi",
    region: "asia-south1",
  },
  async () => {
    const today = ymdInKarachi(new Date());
    const currentHour = hourBucketInKarachi(new Date());
    const targetHour = currentHour + 1;

    const snap = await db
      .collection(COLLECTIONS.APPOINTMENTS)
      .where("appointmentDate", "==", today)
      .where("status", "==", APPOINTMENT_STATUS.BOOKED)
      .get();

    for (const doc of snap.docs) {
      const appt = doc.data();
      const scheduledHour = appt.scheduledHour as number | undefined;
      if (scheduledHour != null && scheduledHour !== targetHour) continue;
      if (!appt.patientUserId) continue;
      if (appt.reminder1hSent === true) continue;

      await createNotification({
        userId: appt.patientUserId,
        type: NOTIFICATION_TYPE.REMINDER_1_HOUR,
        titleEn: "Appointment in 1 hour",
        titleUr: "1 گھنٹے میں appointment",
        bodyEn: `Token ${appt.tokenDisplay}. Please leave for the hospital soon.`,
        bodyUr: `ٹوکن ${appt.tokenDisplay}۔ براہِ کرم جلد روانہ ہوں۔`,
        appointmentId: doc.id,
        doctorId: appt.doctorId,
      });

      await doc.ref.update({
        reminder1hSent: true,
        reminder1hSentAt: Timestamp.now(),
      });
    }
  }
);

async function sendRemindersForDate(
  dateYmd: string,
  type: typeof NOTIFICATION_TYPE.REMINDER_1_DAY,
  copy: {
    titleEn: string;
    titleUr: string;
    bodyEn: (token: string, date: string) => string;
    bodyUr: (token: string, date: string) => string;
  }
): Promise<void> {
  const snap = await db
    .collection(COLLECTIONS.APPOINTMENTS)
    .where("appointmentDate", "==", dateYmd)
    .where("status", "in", [APPOINTMENT_STATUS.BOOKED, APPOINTMENT_STATUS.CHECKED_IN])
    .get();

  for (const doc of snap.docs) {
    const appt = doc.data();
    if (!appt.patientUserId) continue;
    if (appt.reminder1dSent === true) continue;

    await createNotification({
      userId: appt.patientUserId,
      type,
      titleEn: copy.titleEn,
      titleUr: copy.titleUr,
      bodyEn: copy.bodyEn(appt.tokenDisplay, dateYmd),
      bodyUr: copy.bodyUr(appt.tokenDisplay, dateYmd),
      appointmentId: doc.id,
      doctorId: appt.doctorId,
    });

    await doc.ref.update({
      reminder1dSent: true,
      reminder1dSentAt: Timestamp.now(),
    });
  }
}
