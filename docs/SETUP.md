# Setup Guide

## Prerequisites

| Tool | Version | Notes |
|------|---------|--------|
| Flutter | 3.24+ stable | `flutter doctor` must pass Android toolchain |
| Android Studio | Latest | SDK 34+, emulator optional |
| Node.js | 20 LTS | For Cloud Functions |
| Firebase CLI | `npm i -g firebase-tools` | Login & deploy |
| Java JDK | 17 | Android builds |

## Clone and Flutter app

```powershell
cd D:\GitHub\flutter2
flutter pub get
```

### Firebase Android/iOS config

1. Create project **hospital-token-app** in [Firebase Console](https://console.firebase.google.com).
2. Add Android app with package name from `android/app/build.gradle` (`applicationId`).
3. Download `google-services.json` → `android/app/`.
4. (Optional) Add iOS app and `GoogleService-Info.plist` → `ios/Runner/`.
5. Enable **Authentication** (Phone + Email), **Firestore**, **Storage**, **Cloud Messaging**.

### FlutterFire CLI (recommended)

```powershell
dart pub global activate flutterfire_cli
flutterfire configure --project=hospital-token-app
```

This generates `lib/firebase_options.dart`.

## Cloud Functions

```powershell
cd D:\GitHub\flutter2\functions
npm install
npm run build
```

Deploy:

```powershell
cd D:\GitHub\flutter2
firebase deploy --only functions,firestore,storage
```

## Local emulators

```powershell
cd D:\GitHub\flutter2
firebase emulators:start
```

| Service | Port |
|---------|------|
| Firestore | 8080 |
| Functions | 5001 |
| Auth | 9099 |
| Storage | 9199 |
| Emulator UI | 4000 |

Point the Flutter app to emulators in debug (see `04-MODULES_GUIDE.md` — `FirebaseEmulatorConfig`).

## Mock mode (no Firebase) — default

The app ships with **mock mode ON**:

```dart
// lib/core/constants/app_constants.dart
static const bool useMockData = true;
```

- In-memory data: `lib/features/shared/data/mock_data_store.dart`
- Login → pick **Demo role** → any OTP (≥4 digits)
- Token format **T-01**; live queue updates when doctor presses **Call next**
- Set `useMockData = false` only after Firebase is configured

## Environment variables (Functions)

Set in Firebase Console → Functions → Environment variables if needed:

- `HOSPITAL_TIMEZONE=Asia/Karachi` (default in code)

## First admin user

1. Sign up a user via the app (role defaults to `patient` in rules).
2. In Firestore Console, set `users/{uid}.role` to `admin`.
3. Create `staff/{id}` and link `users/{uid}.staffId` for reception staff.

## Urdu / English

- Store user preference: `users.locale` → `en` | `ur`.
- All notification documents include `titleEn`, `titleUr`, `bodyEn`, `bodyUr`.
- Use Flutter `intl` and ARB files under `lib/l10n/`.

## Verify install

```powershell
flutter analyze
flutter test
cd functions; npm run build
```
