import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db, messaging } from "./admin";
import { COLLECTIONS, NOTIFICATION_TYPE } from "./constants";

export type NotificationType =
  (typeof NOTIFICATION_TYPE)[keyof typeof NOTIFICATION_TYPE];

export async function createNotification(params: {
  userId: string;
  type: NotificationType;
  titleEn: string;
  titleUr: string;
  bodyEn: string;
  bodyUr: string;
  appointmentId?: string;
  doctorId?: string;
  data?: Record<string, string>;
}): Promise<string> {
  const ref = await db.collection(COLLECTIONS.NOTIFICATIONS).add({
    userId: params.userId,
    type: params.type,
    titleEn: params.titleEn,
    titleUr: params.titleUr,
    bodyEn: params.bodyEn,
    bodyUr: params.bodyUr,
    appointmentId: params.appointmentId ?? null,
    doctorId: params.doctorId ?? null,
    read: false,
    readAt: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  await sendFcmToUser(params.userId, {
    title: params.titleEn,
    body: params.bodyEn,
    data: {
      type: params.type,
      notificationId: ref.id,
      ...(params.appointmentId ? { appointmentId: params.appointmentId } : {}),
      ...(params.doctorId ? { doctorId: params.doctorId } : {}),
      ...params.data,
    },
  });

  return ref.id;
}

export async function sendFcmToUser(
  userId: string,
  payload: { title: string; body: string; data?: Record<string, string> }
): Promise<void> {
  const tokensSnap = await db
    .collection(COLLECTIONS.FCM_TOKENS)
    .where("userId", "==", userId)
    .get();

  if (tokensSnap.empty) return;

  const tokens = tokensSnap.docs.map((d) => d.data().token as string).filter(Boolean);
  if (!tokens.length) return;

  const message = {
    notification: { title: payload.title, body: payload.body },
    data: payload.data ?? {},
    tokens,
  };

  const result = await messaging.sendEachForMulticast(message);
  const stale: string[] = [];
  result.responses.forEach((resp, i) => {
    if (
      !resp.success &&
      resp.error?.code === "messaging/registration-token-not-registered"
    ) {
      stale.push(tokensSnap.docs[i].id);
    }
  });
  await Promise.all(stale.map((id) => db.collection(COLLECTIONS.FCM_TOKENS).doc(id).delete()));
}

export function tsToDate(ts: Timestamp | undefined): Date | null {
  if (!ts) return null;
  return ts.toDate();
}
