# Security Rules

Files: `firestore.rules`, `storage.rules`.

Principle: **patients own their data**; **staff manage operational collections**; **sensitive writes via Cloud Functions** (rules block client appointment creation).

---

## Role model

| Role | Firestore identity |
|------|-------------------|
| patient | `users/{uid}.role == 'patient'` |
| doctor | `role == 'doctor'` + `doctorId` |
| receptionist | `role == 'receptionist'` |
| nurse | `role == 'nurse'` |
| admin | `role == 'admin'` |

Helpers: `isStaff()`, `isAssignedDoctor(doctorId)`, `patientBelongsToUser(patientId)`.

---

## Firestore summary

| Collection | Read | Create | Update | Delete |
|------------|------|--------|--------|--------|
| users | self, staff | self (patient only) | self (no role change), admin | admin |
| patients | self, staff | patient (own userId) | self, staff | admin, self |
| family_members | owner, staff | patient owner | owner, staff | owner, staff |
| departments | signed-in | admin | admin | admin |
| doctors | signed-in | admin | admin | admin |
| doctor_schedules | signed-in | admin, receptionist | same | same |
| staff | staff | admin | admin | admin |
| appointments | patient own, staff, assigned doctor | **denied** | staff; doctor limited fields | admin |
| daily_token_counters | staff | **denied** | **denied** | **denied** |
| queue_state | signed-in | **denied** | admin, receptionist, assigned doctor | admin |
| notifications | self | **denied** (functions) | self mark read | self, admin |
| feedback | self, staff | self | admin | admin |
| audit_logs | admin | **denied** | **denied** | **denied** |
| fcm_tokens | self | self | self | self |

### queue_state hardening note

Rules allow doctor/receptionist to update `queue_state` for operational flexibility (kiosk/offline contingency). **Recommended production tightening**: set `allow update: if false` and route all mutations through Cloud Functions using Admin SDK (same as `daily_token_counters`).

---

## Storage summary

| Path | Read | Write |
|------|------|-------|
| `doctors/{id}/profile/*` | public | signed-in, image ≤5MB, name pattern |
| `departments/{id}/*` | public | signed-in, image ≤3MB |
| `patients/{userId}/documents/*` | owner | owner, ≤10MB |

---

## Cloud Functions auth

Callables use `requireAuth()` → load `users` doc → `requireRoles` / `requireDoctorForQueue`.

Unauthenticated calls throw `unauthenticated`.

---

## Testing rules

Use Emulator Suite + Rules Playground:

1. Patient A cannot read patient B appointments.
2. Patient cannot `create` appointments document.
3. Patient can `update` own notification `read: true`.
4. Anonymous cannot read `staff`.

---

## Index + rules coupling

Queries from clients must match indexes in `firestore.indexes.json`. Functions using Admin SDK bypass rules but still need indexes.

See [02-DATABASE_SCHEMA.md](02-DATABASE_SCHEMA.md).
