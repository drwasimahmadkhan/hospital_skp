# Testing Checklist

## Unit / widget (Flutter)

- [ ] Token display renders **T-01** format from API (mock JSON)
- [ ] Locale switch EN ↔ UR updates labels and directionality
- [ ] Router sends doctor role to doctor shell
- [ ] Form validation: empty complaint, past date blocked
- [ ] Error mapping for `already-exists` and `resource-exhausted`

## Integration (Firebase emulators)

### Auth

- [ ] Phone sign-in creates user doc
- [ ] Non-admin cannot set `role: admin` on create

### allocateToken

- [ ] First booking returns T-01
- [ ] Second booking same day same doctor → error
- [ ] Counter reaches maxTokens → resource-exhausted
- [ ] Concurrent calls (2 clients) → unique tokens, no over max

### Queue

- [ ] check_in from patient on own BOOKED appointment
- [ ] callNext sets CALLED and sends notification doc
- [ ] complete clears `currentAppointmentId`
- [ ] pause sets queue PAUSED; patients receive DOCTOR_LEAVE type
- [ ] emergency_insert creates token with isEmergency

### graceNoShow

- [ ] CALLED with old `calledAt` → NO_SHOW after job/manual

### Reminders

- [ ] reminder1dSent prevents duplicate next run
- [ ] Hourly reminder respects `scheduledHour`

### Reports

- [ ] getDailyReport totals match seeded appointments
- [ ] Non-admin cannot call getDoctorUtilization

## Security rules (emulator)

- [ ] Patient read own appointment — allow
- [ ] Patient read other appointment — deny
- [ ] Client create appointment — deny
- [ ] Patient update queue_state — deny
- [ ] Receptionist update queue_state — allow (if rule enabled)

## Storage

- [ ] Upload doctor profile JPG — allow
- [ ] Upload 10MB file — deny
- [ ] Patient B read patient A document path — deny

## Device / E2E

- [ ] FCM token registered on login
- [ ] Foreground notification tap opens appointment
- [ ] Live queue updates within 2s of callNext on second device
- [ ] Offline: last token visible from cache

## Performance

- [ ] Doctor queue list ≤ 100 appointments loads < 2s on 4G
- [ ] No unbounded collection queries without date filter

## Accessibility

- [ ] Token text scalable (200%)
- [ ] TalkBack reads token and position in Urdu locale

## Pre-release sign-off

- [ ] `flutter analyze` clean
- [ ] `functions npm run build` clean
- [ ] Production Firebase project IDs not committed in secrets
- [ ] Play Store privacy policy mentions health/phone data
