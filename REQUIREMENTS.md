# Requirements

## System requirements

| Item | Minimum | Notes |
|------|---------|-------|
| OS | Windows 10/11, macOS, or Linux | Android build typically done on Windows/macOS |
| Flutter SDK | 3.22+ stable | https://docs.flutter.dev/get-started/install |
| Dart SDK | Bundled with Flutter | Do not install Dart separately unless needed |
| Git | 2.x | Required to clone this repo |
| RAM | 8 GB+ | 16 GB recommended for Android emulator |
| Disk | ~3 GB free | Flutter SDK + Android toolchain |

## Android run requirements

| Item | Notes |
|------|-------|
| Android Studio | Latest stable |
| Android SDK | API 33+ recommended |
| Emulator or physical device | USB debugging enabled for physical devices |
| Java JDK | 17 recommended (Android Gradle) |

## Flutter app dependencies

Declared in `pubspec.yaml` (installed via `flutter pub get`):

- `flutter` / `flutter_localizations`
- `flutter_riverpod` — state management
- `go_router` — navigation
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging` — optional production backend
- `shared_preferences`, `intl`, `equatable`, `uuid`, `collection`

Install:

```bash
flutter pub get
```

## Optional: Firebase Cloud Functions

Only needed for production Firebase mode.

| Item | Version |
|------|---------|
| Node.js | 18+ (20 LTS recommended) |
| npm | 9+ |
| Firebase CLI | `npm install -g firebase-tools` |

Install function dependencies:

```bash
cd functions
npm install
npm run build
```

Node package list: see `functions/package.json`.

## Optional: browser demo only

If you only want to try the HTML demo:

- Any modern browser (Chrome, Edge, Firefox)
- Open `local_demo/index.html`
- No Flutter / Node / Firebase required

## Verify installation

```bash
flutter --version
flutter doctor
flutter pub get
flutter test
flutter run
```

`flutter doctor` should show no blocking errors for the platform you target (Android / Windows / Chrome).
