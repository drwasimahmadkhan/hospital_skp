/** Shared constants for Hospital Token App (single hospital, Pakistan). */

export const HOSPITAL = {
  id: "hospital_main",
  nameEn: "City Care Hospital",
  nameUr: "سiti کیئر ہسپتال",
  timezone: "Asia/Karachi",
  countryCode: "PK",
  defaultLocale: "en",
  supportedLocales: ["en", "ur"] as const,
};

export const TOKEN = {
  /** Display prefix, e.g. T-01 */
  prefix: "T",
  padLength: 2,
  formatDisplay: (n: number): string =>
    `${TOKEN.prefix}-${String(n).padStart(TOKEN.padLength, "0")}`,
};

export const APPOINTMENT_STATUS = {
  BOOKED: "BOOKED",
  CHECKED_IN: "CHECKED_IN",
  IN_QUEUE: "IN_QUEUE",
  CALLED: "CALLED",
  IN_CONSULTATION: "IN_CONSULTATION",
  COMPLETED: "COMPLETED",
  SKIPPED: "SKIPPED",
  NO_SHOW: "NO_SHOW",
  CANCELLED: "CANCELLED",
} as const;

export type AppointmentStatus =
  (typeof APPOINTMENT_STATUS)[keyof typeof APPOINTMENT_STATUS];

export const QUEUE_STATUS = {
  OPEN: "OPEN",
  PAUSED: "PAUSED",
  CLOSED: "CLOSED",
} as const;

export const NOTIFICATION_TYPE = {
  BOOKING_CONFIRMED: "BOOKING_CONFIRMED",
  REMINDER_1_DAY: "REMINDER_1_DAY",
  REMINDER_1_HOUR: "REMINDER_1_HOUR",
  QUEUE_NEAR: "QUEUE_NEAR",
  YOUR_TURN: "YOUR_TURN",
  DOCTOR_LEAVE: "DOCTOR_LEAVE",
  NO_SHOW_WARNING: "NO_SHOW_WARNING",
  APPOINTMENT_CANCELLED: "APPOINTMENT_CANCELLED",
} as const;

export const ROLES = {
  PATIENT: "patient",
  DOCTOR: "doctor",
  RECEPTIONIST: "receptionist",
  NURSE: "nurse",
  ADMIN: "admin",
} as const;

/** Default max tokens per doctor per day if schedule doc missing. */
export const DEFAULT_MAX_TOKENS_PER_DAY = 80;

/** Patients ahead in queue before QUEUE_NEAR notification. */
export const QUEUE_NEAR_THRESHOLD = 3;

/** Minutes after CALLED before auto no-show (grace). */
export const GRACE_NO_SHOW_MINUTES = 10;

/** Minutes patient should arrive before slot (used in reminders copy). */
export const CHECK_IN_ADVICE_MINUTES = 15;

export const COLLECTIONS = {
  USERS: "users",
  PATIENTS: "patients",
  FAMILY_MEMBERS: "family_members",
  DOCTORS: "doctors",
  DEPARTMENTS: "departments",
  DOCTOR_SCHEDULES: "doctor_schedules",
  APPOINTMENTS: "appointments",
  DAILY_TOKEN_COUNTERS: "daily_token_counters",
  QUEUE_STATE: "queue_state",
  NOTIFICATIONS: "notifications",
  FEEDBACK: "feedback",
  STAFF: "staff",
  AUDIT_LOGS: "audit_logs",
  FCM_TOKENS: "fcm_tokens",
} as const;

export function doctorDayQueueId(doctorId: string, dateYmd: string): string {
  return `${doctorId}_${dateYmd}`;
}

export function dailyCounterId(doctorId: string, dateYmd: string): string {
  return `${doctorId}_${dateYmd}`;
}

/** YYYY-MM-DD in hospital timezone (caller should pass already-normalized date). */
export function assertDateYmd(dateYmd: string): void {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateYmd)) {
    throw new Error("appointmentDate must be YYYY-MM-DD");
  }
}
