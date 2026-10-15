# Hospital SKP — Token & Appointments

Mobile-first hospital appointment app with **live token / queue tracking**. Patients book from home, receive a token automatically, and see how many patients are ahead so they can arrive just in time.

| Role | What you can do |
|------|-----------------|
| Patient | Browse departments/doctors, book, live queue, cancel, feedback |
| Receptionist | Phone / walk-in booking into the same token queue |
| Doctor | Call next, complete, skip, pause / break |
| Admin | Overview KPIs, doctors, departments |

**Default mode:** Local backend (no Firebase). Full demo works offline in memory.

---

## Documentation

| File | Description |
|------|-------------|
| [docs/index.html](docs/index.html) | Full documentation (open in a browser) |
| [REQUIREMENTS.md](REQUIREMENTS.md) | System requirements and dependencies |
| [DOCUMENTATION.md](DOCUMENTATION.md) | Index of detailed markdown docs |
| [local_demo/index.html](local_demo/index.html) | Browser demo if Flutter is not installed yet |

---

## Quick start (recommended)

### 1. Install Flutter

1. Install Flutter SDK (stable): https://docs.flutter.dev/get-started/install  
2. Add Flutter `bin` to your system `PATH`  
3. Verify:

```bash
flutter doctor
```

You need at least:

- Flutter 3.22+ (stable)
- Android Studio / Android SDK (for Android)
- A device or emulator

### 2. Clone this repository

```bash
git clone https://github.com/drwasimahmadkhan/hospital_skp.git
cd hospital_skp
```

### 3. Install Flutter packages

```bash
flutter pub get
```

### 4. Run the app

```bash
# List devices
flutter devices

# Run (Android emulator / phone)
flutter run
```

Windows desktop (optional):

```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

Chrome (optional):

```bash
flutter run -d chrome
```

### 5. Demo login (Local mode)

Local mode is **ON** by default (`AppConstants.useMockData = true`).

1. Finish or skip onboarding  
2. Choose a **Demo role**: `patient` / `receptionist` / `doctor` / `admin`  
3. Phone: `03001234567`  
4. OTP: `123456` (any code with 4+ digits works in Local mode)

**Patient path:** Home → Department → Doctor → Book → Confirmation → Live Queue  

**Doctor path:** Login as doctor → **Call next** (patient live queue updates)

---

## Browser demo (no Flutter)

If Flutter is not installed yet:

1. Open `local_demo/index.html` in Chrome / Edge  
2. Pick a role → OTP `123456` → use the same flows  

This is a lightweight HTML demo of the same token/queue logic.

---

## Project structure

```text
hospital_skp/
├── lib/                 Flutter app (auth, booking, live queue, roles)
├── local_demo/          Browser demo (no Flutter required)
├── docs/                Documentation (HTML + markdown)
├── functions/           Firebase Cloud Functions (optional production)
├── test/                Unit tests
├── pubspec.yaml         Flutter dependencies
├── REQUIREMENTS.md      Install requirements
└── README.md            This file
```

---

## Configuration

### Local mode (default — no Firebase)

File: `lib/core/constants/app_constants.dart`

```dart
static const bool useMockData = true;
```

Use this for development and demos.

### Firebase mode (optional production)

Only when you need real SMS OTP, multi-device sync, and push notifications:

1. Set `useMockData = false`  
2. Create a Firebase project and run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

3. Enable Phone Auth, Firestore, Cloud Messaging  
4. Deploy backend:

```bash
cd functions
npm install
npm run build
cd ..
firebase deploy
```

See `docs/SETUP.md` and `docs/index.html` for details.

---

## Tests

```bash
flutter test
```

---

## Tech stack

- Flutter + Riverpod + go_router  
- Local in-memory backend for demos  
- Optional Firebase (Auth, Firestore, Cloud Functions, FCM)  
- Token format: `T-01`, `T-02`, … per doctor per day  

---

## License

Private hospital use unless otherwise stated by the repository owner.
