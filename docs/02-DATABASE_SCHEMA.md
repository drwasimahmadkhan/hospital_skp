# Database Schema (Firestore)

All timestamps: `Timestamp` (server). Dates for booking days: string **`YYYY-MM-DD`** in `Asia/Karachi`.

Token display: **`tokenDisplay`** e.g. `T-01`; numeric sort uses **`tokenNumber`** (int; emergency may use fractional internal value).

---

## `users`

Auth profile linked to Firebase Auth UID (document id = `uid`).

| Field | Type | Description |
|-------|------|-------------|
| role | string | `patient` \| `doctor` \| `receptionist` \| `nurse` \| `admin` |
| displayName | string | |
| phone | string | E.164 preferred |
| email | string? | |
| locale | string | `en` \| `ur` |
| doctorId | string? | If role doctor → `doctors` doc id |
| staffId | string? | If staff → `staff` doc id |
| photoUrl | string? | |
| createdAt | timestamp | |
| updatedAt | timestamp | |

**Indexes**: none required beyond doc id.

---

## `patients`

Clinical/demographic record (may differ from auth user when booking for family).

| Field | Type | Description |
|-------|------|-------------|
| userId | string | Owner auth uid |
| fullName | string | |
| fullNameUr | string? | |
| gender | string? | |
| dateOfBirth | string? | ISO date |
| cnic | string? | Pakistan CNIC |
| phone | string | |
| createdAt | timestamp | |
| updatedAt | timestamp | |

**Indexes**: `userId + createdAt` (composite).

---

## `family_members`

| Field | Type | Description |
|-------|------|-------------|
| ownerUserId | string | Account holder |
| fullName | string | |
| relation | string | e.g. son, wife |
| dateOfBirth | string? | |
| gender | string? | |
| createdAt | timestamp | |

**Indexes**: `ownerUserId + createdAt`.

---

## `departments`

| Field | Type | Description |
|-------|------|-------------|
| nameEn | string | |
| nameUr | string | |
| descriptionEn | string? | |
| descriptionUr | string? | |
| sortOrder | number | |
| isActive | boolean | |
| iconUrl | string? | Storage path |

---

## `doctors`

| Field | Type | Description |
|-------|------|-------------|
| departmentId | string | |
| nameEn | string | |
| nameUr | string | |
| qualificationsEn | string? | |
| qualificationsUr | string? | |
| feePkr | number | |
| photoUrl | string? | |
| isActive | boolean | |
| avgRating | number? | Denormalized from feedback |
| createdAt | timestamp | |

---

## `doctor_schedules`

| Field | Type | Description |
|-------|------|-------------|
| doctorId | string | |
| dayOfWeek | number | 1=Mon … 7=Sun (or 0–6 — document in app constants) |
| startTime | string | `HH:mm` |
| endTime | string | `HH:mm` |
| maxTokensPerDay | number | Default cap e.g. 80 |
| isActive | boolean | |

**Indexes**: `doctorId + dayOfWeek`.

---

## `appointments`

Primary booking record; token embedded (no separate `tokens` collection).

| Field | Type | Description |
|-------|------|-------------|
| doctorId | string | |
| departmentId | string? | |
| patientId | string | |
| patientUserId | string | For rules/queries |
| familyMemberId | string? | |
| appointmentDate | string | YYYY-MM-DD |
| tokenNumber | number | Sort key |
| tokenDisplay | string | T-01 |
| status | string | See FEATURES doc |
| chiefComplaint | string | |
| locale | string | |
| bookedByUid | string | |
| isEmergency | boolean? | |
| scheduledHour | number? | Optional for 1h reminder |
| checkedInAt | timestamp? | |
| calledAt | timestamp? | |
| completedAt | timestamp? | |
| reminder1dSent | boolean? | |
| reminder1hSent | boolean? | |
| createdAt | timestamp | |
| updatedAt | timestamp | |

**Indexes** (see `firestore.indexes.json`):

- `patientUserId + appointmentDate DESC + createdAt DESC`
- `patientId + appointmentDate`
- `doctorId + appointmentDate + tokenNumber`
- `doctorId + appointmentDate + status`
- `doctorId + appointmentDate + patientId` (duplicate detection)
- `status + calledAt` (grace no-show)

---

## `daily_token_counters`

Server-only writes.

| Field | Type | Description |
|-------|------|-------------|
| doctorId | string | |
| appointmentDate | string | |
| lastTokenNumber | number | |
| maxTokens | number | Snapshot at allocation time |
| updatedAt | timestamp | |

Document id: `{doctorId}_{appointmentDate}`.

---

## `queue_state`

One doc per doctor per day. Document id: `{doctorId}_{appointmentDate}`.

| Field | Type | Description |
|-------|------|-------------|
| doctorId | string | |
| appointmentDate | string | |
| status | string | `OPEN` \| `PAUSED` \| `CLOSED` |
| currentTokenNumber | number | Last called token number |
| currentAppointmentId | string? | Active CALLED/IN_CONSULTATION |
| lastCalledToken | number | For near notifications |
| pausedAt | timestamp? | |
| pausedReason | string? | |
| totalBooked | number | |
| totalCompleted | number | |
| updatedAt | timestamp | |

---

## `notifications`

| Field | Type | Description |
|-------|------|-------------|
| userId | string | |
| type | string | BOOKING_CONFIRMED, QUEUE_NEAR, … |
| titleEn, titleUr | string | |
| bodyEn, bodyUr | string | |
| appointmentId | string? | |
| doctorId | string? | |
| read | boolean | |
| readAt | timestamp? | |
| createdAt | timestamp | |
| updatedAt | timestamp | |

**Indexes**: `userId + createdAt DESC`; `userId + read + createdAt DESC`.

---

## `feedback`

| Field | Type | Description |
|-------|------|-------------|
| userId | string | |
| appointmentId | string | |
| doctorId | string | |
| rating | number | 1–5 |
| comment | string? | |
| createdAt | timestamp | |

**Indexes**: `doctorId + createdAt DESC`.

---

## `staff`

| Field | Type | Description |
|-------|------|-------------|
| fullName | string | |
| role | string | receptionist, nurse, admin |
| phone | string | |
| isActive | boolean | |
| createdAt | timestamp | |

Linked from `users.staffId`.

---

## `audit_logs`

Append-only (functions).

| Field | Type | Description |
|-------|------|-------------|
| action | string | TOKEN_ALLOCATED, QUEUE_CALL_NEXT, … |
| actorUid | string | |
| actorRole | string? | |
| targetType | string | |
| targetId | string | |
| metadata | map? | |
| createdAt | timestamp | |

**Indexes**: `action + createdAt DESC`.

---

## `fcm_tokens`

| Field | Type | Description |
|-------|------|-------------|
| userId | string | |
| token | string | FCM registration token |
| platform | string | android \| ios |
| updatedAt | timestamp | |

---

## Relationships (ER summary)

```
users 1──* patients
users 1──* family_members
departments 1──* doctors
doctors 1──* doctor_schedules
doctors 1──* appointments
patients 1──* appointments
appointments *──1 queue_state (by doctorId+date)
users 1──* notifications
appointments 1──0..1 feedback
```

---

## Storage paths

| Path | Purpose |
|------|---------|
| `doctors/{doctorId}/profile/profile.jpg` | Doctor photo |
| `departments/{id}/banner.png` | Optional |
| `patients/{userId}/documents/*` | Patient uploads |

See [06-SECURITY_RULES.md](06-SECURITY_RULES.md).
