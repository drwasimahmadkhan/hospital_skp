# Screens Specification

Navigation: **go_router** with role-based shells. Primary color: hospital teal `#00796B`. Token hero font: bold 48sp, monospace digits.

Token format everywhere: **T-01** (from `tokenDisplay` field).

---

## Shared components

| Component | Usage |
|-----------|--------|
| `AppScaffold` | AppBar + drawer/bottom nav |
| `TokenBadge` | Large T-01 chip |
| `DoctorCard` | Photo, nameEn/nameUr, fee PKR |
| `QueueProgressBar` | Visual tokens ahead |
| `BilingualText` | EN primary, UR subtitle |
| `EmptyState` | Illustration + CTA |
| `ErrorBanner` | Functions error codes |

---

## Patient flow

### 1. Splash

- Logo, hospital name EN/UR
- Auto-nav: logged in → Home; else → Login
- Duration 1.5s

### 2. Login

- Phone input (+92 default country)
- OTP 6 digits
- Terms link footer

### 3. Profile setup (first time)

- Full name, gender optional, locale toggle
- Save → creates `patients` + `users`

### 4. Home

- **AppBar**: notifications icon (unread count)
- **Cards**: Next appointment (TokenBadge, doctor, date)
- **Actions**: Book appointment, My tokens, Family
- **Bottom nav**: Home, Book, Queue, Profile

### 5. Departments

- List `departments` active, sortOrder
- Search filter

### 6. Doctor list

- Filter by department
- DoctorCard → tap detail

### 7. Doctor detail

- Photo, qualifications, fee, today’s schedule snippet
- CTA **Book token**
- Reviews summary (avgRating)

### 8. Book — select date

- Calendar (Karachi TZ), disable non-schedule days
- Show remaining tokens estimate (`max - totalBooked`)

### 9. Book — confirm

- Patient selector (self / family member)
- Chief complaint multiline
- Confirm → loading → callable allocateToken

### 10. Booking success

- Confetti optional
- TokenBadge T-01 animated
- Buttons: View queue, Share (screenshot)

### 11. My appointments

- Tabs: Upcoming | Past
- List tile: date, doctor, token, status chip

### 12. Appointment detail

- Full status timeline
- Check-in button when BOOKED and date is today
- Cancel (future: callable)

### 13. Live queue

- Current serving token (from queue_state)
- Your token highlighted
- “X patients ahead”
- Pull-to-refresh
- Pause banner if queue PAUSED

### 14. Notifications inbox

- List `notifications`, bilingual title/body by locale
- Mark read on tap

### 15. Family members

- CRUD family_members
- Used in booking selector

### 16. Profile

- Edit name, phone, locale
- Logout

### 17. Feedback

- Stars 1–5, comment
- Submit → `feedback` collection

---

## Doctor flow

### D1. Doctor login

- Same auth; role routes here

### D2. Doctor home (today)

- Queue stats: booked, completed, waiting
- Big **Call next** FAB
- Pause/resume toggle

### D3. Queue list

- Sorted tokens, status color
- Tap row → patient complaint sheet

### D4. Active patient sheet

- Actions: Start consultation, Complete, Skip, No-show

---

## Reception flow

### R1. Staff dashboard

- Doctor dropdown
- Queue snapshot cards

### R2. Patient search

- Phone/CNIC → open profile + today appointments

### R3. Emergency insert

- Form: patient, complaint → emergency_insert

---

## Admin flow

### A1. Admin dashboard

- KPI tiles from getDailyReport

### A2. Doctors CRUD

- Form EN/UR names, department, fee
- Photo upload picker → Storage

### A3. Schedules

- Per doctor weekly grid, maxTokensPerDay

### A4. Staff users

- Link uid to staff record, set role

---

## Navigation map (patient)

```
/splash
/login
/onboarding
/home
/departments
/departments/:id/doctors
/doctors/:id
/book/:doctorId/date
/book/:doctorId/confirm
/book/success
/appointments
/appointments/:id
/queue/:appointmentId
/notifications
/family
/profile
/feedback/:appointmentId
```

## Navigation map (doctor)

```
/doctor/home
/doctor/queue
/doctor/patient/:appointmentId
```

---

## State & loading

- Shimmer on lists
- Disable double-tap on Book confirm
- Optimistic UI only for mark notification read (not for booking)

See [01-FEATURES_AND_FLOWS.md](01-FEATURES_AND_FLOWS.md) for behavioral flows.
