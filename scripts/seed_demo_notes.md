# Seed data notes (production Firebase)

After deploying rules, create documents manually or via Admin SDK:

1. `departments` — Cardiology, General Medicine, Pediatrics, Orthopedics (nameEn/nameUr).
2. `doctors` — link `userId` of doctor auth accounts; set `maxTokensPerDay`, `avgConsultMinutes`, `feePkr`.
3. `doctor_schedules` — weekdays 1–6, `09:00`–`17:00`, break `13:00`–`14:00`.
4. `users` — set `role` for receptionist/doctor/admin UIDs after phone login once.
5. `queue_state/{doctorId}_{yyyy-MM-dd}` — created automatically by `allocateToken` on first booking.

Mock mode already seeds equivalent data in `MockDataStore` — no Firebase required for demos.