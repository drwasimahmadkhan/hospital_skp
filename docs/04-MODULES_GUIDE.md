# Modules Guide

How major app modules integrate with Firebase. Code paths refer to the intended Flutter layout in [03-PROJECT_STRUCTURE.md](03-PROJECT_STRUCTURE.md).

---

## Auth

**Firebase**: Authentication (Phone primary for Pakistan, Email optional).

**Flow**:

1. `lib/features/auth/` — OTP UI, `FirebaseAuth.signInWithCredential`.
2. On first sign-in, create `users/{uid}` with `role: patient` (allowed by rules).
3. Load role → route: patient `/home`, doctor `/doctor`, reception `/staff`, admin `/admin`.

**Pointers**:

- Role gate: `lib/core/routing/app_router.dart` — redirect by `users.role`.
- Staff/doctor: admin sets `doctorId` / `staffId` on user doc.

**Emulator**: `FirebaseAuth.instance.useAuthEmulator('localhost', 9099);`

---

## Booking (token allocation)

**Never** write `appointments` from client. Always call Cloud Function.

```dart
// lib/services/cloud_functions_service.dart
final callable = FirebaseFunctions.instanceFor(region: 'asia-south1')
    .httpsCallable('allocateToken');
final result = await callable.call({
  'doctorId': doctorId,
  'patientId': patientId,
  'appointmentDate': '2026-10-15',
  'chiefComplaint': complaint,
});
// result.data: appointmentId, tokenDisplay (T-01), tokenNumber, status
```

**Client validation** before call:

- Selected date matches doctor schedule `dayOfWeek`.
- Patient profile exists.

**Repository**: `lib/data/repositories/appointment_repository.dart` → wraps callable + caches result.

---

## Queue (realtime)

**Read**:

- `queue_state/{doctorId}_{date}` — `Stream` for current token, pause state.
- `appointments` query: `doctorId + appointmentDate + orderBy tokenNumber` (staff/doctor).

**Write** (via functions):

| Action | Callable | Role |
|--------|----------|------|
| Check-in | `updateQueueStatus` `{ action: 'check_in' }` | Patient (own) / staff |
| Call next | `callNext` | Doctor / reception |
| Complete / skip / no-show | `updateQueueStatus` | Doctor / reception |
| Pause / resume | `updateQueueStatus` | Doctor / reception |
| Emergency | `updateQueueStatus` `{ action: 'emergency_insert' }` | Doctor / reception |

**Patient “tokens ahead”**:

```dart
final queue = queueState.lastCalledToken;
final mine = appointment.tokenNumber;
final ahead = max(0, (mine - queue).floor());
```

**Pointers**:

- `lib/features/queue/presentation/live_queue_screen.dart`
- `lib/data/repositories/queue_repository.dart`

---

## Realtime listeners

Use `snapshots()` with narrow queries to minimize reads.

| Screen | Listener |
|--------|----------|
| Patient home | `appointments` where `patientUserId == uid` and `appointmentDate >= today` |
| Live queue | `queue_state` doc + single appointment doc |
| Doctor board | `queue_state` + appointments for today |

Disconnect listeners in `dispose` / Riverpod `autoDispose`.

---

## Notifications

**In-app**: `notifications` where `userId == uid` orderBy `createdAt` desc.

**FCM**:

1. On login, request permission → `FirebaseMessaging.getToken()`.
2. Write `fcm_tokens` doc `{ userId, token, platform }`.
3. Handle foreground: `FirebaseMessaging.onMessage` → local notification plugin.
4. Tap handler: read `data.appointmentId` → navigate to appointment detail.

**Server-side**: Functions write `notifications/*` and multicast FCM (`functions/src/utils/notify.ts`).

**Types**: see `NOTIFICATION_TYPE` in `functions/src/utils/constants.ts`.

---

## Mock mode

When `MOCK_MODE=true`:

- Swap `AppointmentRepository` with `MockAppointmentRepository` in `lib/main.dart` provider scope.
- Simulate queue with `Stream.periodic` updating fake `QueueState`.

---

## Error handling

Map `FirebaseFunctionsException`:

| Code | User message (EN) |
|------|-------------------|
| already-exists | You already have a token with this doctor today. |
| resource-exhausted | All tokens are booked for this date. |
| failed-precondition | Queue paused or doctor unavailable. |

Show Urdu strings from `lib/l10n/app_ur.arb`.

---

## Related

- [05-CLOUD_FUNCTIONS.md](05-CLOUD_FUNCTIONS.md)
- [06-SECURITY_RULES.md](06-SECURITY_RULES.md)
