# Architecture

- **Presentation**: Flutter screens + Riverpod controllers/providers.
- **Data**: Repositories talk to Firestore / Auth / FCM, or mock in-memory stores when `AppConstants.useMockData` is true.
- **Routing**: `go_router` with role-based redirects after login (patient → `/home`, receptionist → `/receptionist`, doctor → `/doctor`).

## Queue

Live queue documents: `queue_state/{doctorId}_{yyyy-MM-dd}`. Token allocation runs in Cloud Function `allocateToken` (Firestore transaction) to avoid race conditions.

## OTP

Pakistan numbers validated as 10-digit `3XXXXXXXXX`, stored/sent as E.164 `+92…`.
