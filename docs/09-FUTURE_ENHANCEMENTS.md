# Future Enhancements

Prioritized roadmap beyond MVP token queue.

## P1 — High value

| Item | Description |
|------|-------------|
| Online payment | JazzCash/Easypaisa deposit to confirm token |
| SMS fallback | Urdu SMS when FCM unavailable |
| Multi-counter queues | Per-department display boards (TV mode) |
| Walk-in without smartphone | Reception prints thermal token slip |
| Harden queue writes | Deny all client `queue_state` updates; functions only |

## P2 — Operations

| Item | Description |
|------|-------------|
| Lab/radiology queue | Separate token series L-01 |
| Appointment reschedule | Move date with counter migration rules |
| Doctor leave calendar | Block booking on leave days |
| Wait time ML | Estimate minutes from historical service time |
| Export reports | CSV/PDF to admin email |

## P3 — Patient experience

| Item | Description |
|------|-------------|
| WhatsApp reminders | Meta Business API |
| Family dashboard | One view for all members’ tokens |
| Video consult hook | Jitsi/Zoom link on IN_CONSULTATION |
| Health records vault | Encrypted Storage with strict rules |
| Ratings moderation | Hide abusive feedback |

## P4 — Scale (if multi-branch later)

| Item | Description |
|------|-------------|
| HospitalId on all docs | Tenant isolation |
| Super-admin console | Chain management |
| FHIR export | Interop with EMR |

## Technical debt

- Replace fractional emergency tokens with explicit `priorityRank` field
- Idempotency keys on `allocateToken` for retry-safe mobile networks
- Dead letter queue for failed FCM sends
- Integration tests in CI with emulators

## Security

- App Check enforcement on all callables
- Custom claims for roles (reduce Firestore reads on every function)
- Periodic rules audit automated in CI
