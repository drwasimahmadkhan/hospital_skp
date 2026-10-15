import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { db } from "./admin";
import { COLLECTIONS, ROLES } from "./constants";

export type UserRole = (typeof ROLES)[keyof typeof ROLES];

export interface AuthUser {
  uid: string;
  role: UserRole;
  doctorId?: string;
  staffId?: string;
}

export async function requireAuth(
  request: CallableRequest<unknown>
): Promise<AuthUser> {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const snap = await db.collection(COLLECTIONS.USERS).doc(request.auth.uid).get();
  if (!snap.exists) {
    throw new HttpsError("failed-precondition", "User profile not found.");
  }
  const data = snap.data()!;
  return {
    uid: request.auth.uid,
    role: data.role as UserRole,
    doctorId: data.doctorId,
    staffId: data.staffId,
  };
}

export function requireRoles(user: AuthUser, allowed: UserRole[]): void {
  if (!allowed.includes(user.role)) {
    throw new HttpsError("permission-denied", "Insufficient role.");
  }
}

export function requireDoctorForQueue(
  user: AuthUser,
  doctorId: string
): void {
  if (user.role === ROLES.ADMIN || user.role === ROLES.RECEPTIONIST) {
    return;
  }
  if (user.role === ROLES.DOCTOR && user.doctorId === doctorId) {
    return;
  }
  throw new HttpsError("permission-denied", "Not assigned to this doctor queue.");
}
