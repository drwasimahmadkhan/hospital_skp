import { Query } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../utils/admin";
import { requireAuth, requireRoles } from "../utils/auth";
import {
  APPOINTMENT_STATUS,
  COLLECTIONS,
  ROLES,
} from "../utils/constants";

export interface DailyReportRequest {
  appointmentDate: string;
  doctorId?: string;
}

export interface DailyReportResponse {
  appointmentDate: string;
  totals: {
    booked: number;
    checkedIn: number;
    completed: number;
    noShow: number;
    cancelled: number;
  };
  byDoctor: Array<{
    doctorId: string;
    booked: number;
    completed: number;
    noShow: number;
  }>;
}

export const getDailyReport = onCall(
  { region: "asia-south1" },
  async (request): Promise<DailyReportResponse> => {
    const user = await requireAuth(request);
    requireRoles(user, [ROLES.ADMIN, ROLES.RECEPTIONIST]);

    const data = request.data as DailyReportRequest;
    if (!data?.appointmentDate) {
      throw new HttpsError("invalid-argument", "appointmentDate required.");
    }

    let query = db
      .collection(COLLECTIONS.APPOINTMENTS)
      .where("appointmentDate", "==", data.appointmentDate) as Query;

    if (data.doctorId) {
      query = query.where("doctorId", "==", data.doctorId);
    }

    const snap = await query.get();
    const totals = {
      booked: 0,
      checkedIn: 0,
      completed: 0,
      noShow: 0,
      cancelled: 0,
    };
    const byDoctorMap = new Map<
      string,
      { booked: number; completed: number; noShow: number }
    >();

    for (const doc of snap.docs) {
      const a = doc.data();
      const doctorId = a.doctorId as string;
      if (!byDoctorMap.has(doctorId)) {
        byDoctorMap.set(doctorId, { booked: 0, completed: 0, noShow: 0 });
      }
      const row = byDoctorMap.get(doctorId)!;

      switch (a.status) {
        case APPOINTMENT_STATUS.BOOKED:
          totals.booked += 1;
          row.booked += 1;
          break;
        case APPOINTMENT_STATUS.CHECKED_IN:
        case APPOINTMENT_STATUS.IN_QUEUE:
        case APPOINTMENT_STATUS.CALLED:
        case APPOINTMENT_STATUS.IN_CONSULTATION:
          totals.checkedIn += 1;
          break;
        case APPOINTMENT_STATUS.COMPLETED:
          totals.completed += 1;
          row.completed += 1;
          break;
        case APPOINTMENT_STATUS.NO_SHOW:
          totals.noShow += 1;
          row.noShow += 1;
          break;
        case APPOINTMENT_STATUS.CANCELLED:
          totals.cancelled += 1;
          break;
        default:
          totals.booked += 1;
          row.booked += 1;
      }
    }

    return {
      appointmentDate: data.appointmentDate,
      totals,
      byDoctor: Array.from(byDoctorMap.entries()).map(([doctorId, stats]) => ({
        doctorId,
        ...stats,
      })),
    };
  }
);

export const getDoctorUtilization = onCall(
  { region: "asia-south1" },
  async (request) => {
    const user = await requireAuth(request);
    requireRoles(user, [ROLES.ADMIN]);

    const { doctorId, fromDate, toDate } = request.data as {
      doctorId: string;
      fromDate: string;
      toDate: string;
    };
    if (!doctorId || !fromDate || !toDate) {
      throw new HttpsError("invalid-argument", "doctorId, fromDate, toDate required.");
    }

    const snap = await db
      .collection(COLLECTIONS.APPOINTMENTS)
      .where("doctorId", "==", doctorId)
      .where("appointmentDate", ">=", fromDate)
      .where("appointmentDate", "<=", toDate)
      .get();

    let completed = 0;
    let booked = 0;
    for (const doc of snap.docs) {
      const st = doc.data().status;
      if (st === APPOINTMENT_STATUS.COMPLETED) completed += 1;
      if (st === APPOINTMENT_STATUS.BOOKED) booked += 1;
    }

    return {
      doctorId,
      fromDate,
      toDate,
      appointmentCount: snap.size,
      completed,
      booked,
      completionRate: snap.size ? completed / snap.size : 0,
    };
  }
);
