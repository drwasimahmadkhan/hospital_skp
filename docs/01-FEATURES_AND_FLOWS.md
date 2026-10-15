# Features and User Flows

Hospital: **City Care Hospital** (single site, Pakistan). Languages: **English + Urdu**. Token format: **T-01** (prefix `T`, zero-padded number).

## Feature list

### Patient

- Phone/email sign-in (Firebase Auth)
- Profile + CNIC optional, emergency contact
- Family members (book for spouse/child)
- Browse departments and doctors (photo, fee, timings)
- Book token for a date (one active booking per doctor per day)
- View token card (T-01), QR optional
- Live queue position (tokens ahead)
- Check-in when arrived at hospital
- Push/in-app notifications (booking, 3 ahead, your turn, reminders)
- Appointment history
- Feedback after visit (1–5 stars + comment)
- Bilingual UI toggle

### Reception / nurse

- Search patient by phone/CNIC
- Manual check-in override
- View all queues for the day
- Emergency insert (priority token)
- Daily print/export list (future: PDF)

### Doctor

- Today’s queue dashboard
- Call next, start consultation, complete, skip, no-show
- Pause queue (break/emergency) with reason
- View patient chief complaint

### Admin

- Manage departments, doctors, schedules, max tokens/day
- Staff accounts and roles
- Upload doctor profile photo (Storage)
- Daily reports (booked/completed/no-show)
- Audit log read-only

---

## Flow diagrams (text)

### Patient — first booking

```
[Splash] → [Login OTP] → [Create profile]
    → [Home]
    → [Departments] → [Doctor list] → [Doctor detail]
    → [Select date] → [Confirm booking]
    → (Cloud Function allocateToken)
    → [Token success T-01] → [Home with upcoming card]
```

### Patient — appointment day

```
[Home] → [My appointment]
    → [Check-in] (updateQueueStatus check_in)
    → [Live queue screen] (listen queue_state + appointments)
    → (Notification: 3 ahead)
    → (Notification: Your turn)
    → [In consultation] (doctor sets IN_CONSULTATION)
    → [Completed] → [Feedback optional]
```

### Doctor — clinic session

```
[Staff login] → [Doctor home today]
    → [Queue list sorted by token]
    → [Call next] → current patient CALLED
    → [Start consultation] → IN_CONSULTATION
    → [Complete] → COMPLETED, queue pointer cleared
    → repeat OR [Pause queue] → patients notified (DOCTOR_LEAVE)
```

### Reception — emergency

```
[Reception dashboard] → [Doctor queue]
    → [Emergency insert] → patient + complaint
    → Token T-E01 (priority) inserted
    → Doctor calls next (emergency floats by tokenNumber 0.5 logic)
```

### Admin — configure doctor

```
[Admin login] → [Doctors] → [Add/Edit]
    → department, nameEn/nameUr, fee, isActive
    → [Schedule] dayOfWeek, startTime, endTime, maxTokensPerDay
    → [Upload photo] → Storage doctors/{id}/profile/
    → Publish → patients see updated listing
```

---

## Appointment status machine

```
BOOKED → CHECKED_IN → IN_QUEUE (optional alias) → CALLED → IN_CONSULTATION → COMPLETED
   ↓         ↓              ↓                      ↓
CANCELLED  (no-show)     SKIPPED              NO_SHOW (grace job)
```

---

## Non-functional requirements

- **Concurrency**: token allocation via Firestore transaction + `daily_token_counters`
- **Timezone**: Asia/Karachi for all dates
- **Offline**: patient can view last cached token; booking requires network
- **Accessibility**: large token text, high contrast, Urdu RTL layout where applicable

See [10-SCREENS_SPEC.md](10-SCREENS_SPEC.md) for UI details.
