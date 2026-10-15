# Cloud Functions

Region: **asia-south1**. Entry: `functions/src/index.ts`.

Build: `cd functions && npm run build` → output `functions/lib/`.

---

## Callable functions

### `allocateToken`

**File**: `functions/src/tokens/allocateToken.ts`

**Auth**: Patient (own patientId) or staff.

**Input**:

```json
{
  "doctorId": "string",
  "patientId": "string",
  "appointmentDate": "YYYY-MM-DD",
  "departmentId": "optional",
  "familyMemberId": "optional",
  "chiefComplaint": "optional",
  "locale": "en|ur"
}
```

**Logic**:

- Transaction: duplicate active appointment same patient+doctor+day
- Increment `daily_token_counters/{doctorId_date}`
- Enforce `maxTokensPerDay` from schedule
- Create `appointments` with `status: BOOKED`, `tokenDisplay` like **T-01**
- Initialize or bump `queue_state.totalBooked`
- Audit log `TOKEN_ALLOCATED`

**Output**: `{ appointmentId, tokenNumber, tokenDisplay, status }`

---

### `callNext`

**File**: `functions/src/queue/callNext.ts`

**Auth**: Doctor (assigned), receptionist, admin.

**Input**: `{ doctorId, appointmentDate }`

**Logic**:

- Fail if queue PAUSED/CLOSED or current patient still CALLED/IN_CONSULTATION
- Next appointment by `tokenNumber` among BOOKED/CHECKED_IN/IN_QUEUE
- Set `CALLED`, update `queue_state.currentAppointmentId`
- Notify patient `YOUR_TURN` + FCM

---

### `updateQueueStatus`

**File**: `functions/src/queue/updateStatus.ts`

**Actions**:

| action | Description |
|--------|-------------|
| check_in | Patient/staff → CHECKED_IN |
| complete | COMPLETED, clear queue pointer, increment totalCompleted |
| skip | SKIPPED |
| no_show | NO_SHOW |
| start_consultation | IN_CONSULTATION |
| pause / resume | queue_state status |
| emergency_insert | Priority appointment T-E** |

---

### `graceNoShowManual`

**File**: `functions/src/queue/graceNoShow.ts`

**Auth**: admin, receptionist.

Runs same logic as scheduler; returns `{ processed: number }`.

---

### `getDailyReport` / `getDoctorUtilization`

**File**: `functions/src/admin/reports.ts`

**Auth**: admin (utilization), admin + receptionist (daily report).

Aggregates appointment counts by status and by doctor.

---

## Scheduled functions

| Function | Schedule | Purpose |
|----------|----------|---------|
| `graceNoShowScheduled` | every 5 min | CALLED → NO_SHOW after 10 min |
| `reminderOneDayBefore` | 09:00 PKT daily | Tomorrow appointments |
| `reminderOneHourBefore` | hourly | Same-day `scheduledHour` match |

---

## Firestore triggers

| Function | Event | Purpose |
|----------|-------|---------|
| `onAppointmentCreated` | appointments create | Booking confirmed notification |
| `onQueueStateUpdated` | queue_state update | QUEUE_NEAR (3 tokens) |
| `onDoctorQueuePaused` | queue status → PAUSED | DOCTOR_LEAVE blast |

**File**: `functions/src/notifications/triggers.ts`

---

## Client invocation (Flutter)

```dart
FirebaseFunctions.instanceFor(region: 'asia-south1').useFunctionsEmulator('localhost', 5001); // debug only

await FirebaseFunctions.instanceFor(region: 'asia-south1')
  .httpsCallable('callNext')
  .call({'doctorId': id, 'appointmentDate': date});
```

---

## Deployment

```bash
firebase deploy --only functions
```

Deploy indexes before production queries:

```bash
firebase deploy --only firestore:indexes
```

---

## Local testing

1. Start emulators: `firebase emulators:start`
2. Seed doctor/patient docs in Emulator UI.
3. Call functions from Flutter or `firebase functions:shell`.

---

## Constants

Shared with documentation: `functions/src/utils/constants.ts` (`TOKEN.prefix`, `GRACE_NO_SHOW_MINUTES`, etc.).
