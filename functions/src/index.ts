/**
 * Hospital Token / Appointment App — Cloud Functions (Firebase v2)
 * Region: asia-south1 (Mumbai — low latency for Pakistan)
 */

export { allocateToken } from "./tokens/allocateToken";
export { callNext } from "./queue/callNext";
export { updateQueueStatus } from "./queue/updateStatus";
export {
  graceNoShowScheduled,
  graceNoShowManual,
} from "./queue/graceNoShow";

export {
  onAppointmentCreated,
  onQueueStateUpdated,
  onDoctorQueuePaused,
} from "./notifications/triggers";

export {
  reminderOneDayBefore,
  reminderOneHourBefore,
} from "./notifications/reminders";

export { getDailyReport, getDoctorUtilization } from "./admin/reports";
