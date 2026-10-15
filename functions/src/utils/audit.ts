import { FieldValue } from "firebase-admin/firestore";
import { db } from "./admin";
import { COLLECTIONS } from "./constants";

export async function writeAuditLog(params: {
  action: string;
  actorUid: string;
  actorRole?: string;
  targetType: string;
  targetId: string;
  metadata?: Record<string, unknown>;
}): Promise<void> {
  await db.collection(COLLECTIONS.AUDIT_LOGS).add({
    ...params,
    createdAt: FieldValue.serverTimestamp(),
  });
}
