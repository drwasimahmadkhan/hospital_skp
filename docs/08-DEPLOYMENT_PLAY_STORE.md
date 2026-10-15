# Deployment & Play Store

## Firebase production setup

1. Create production project or use `hospital-token-app`.
2. Enable billing (Blaze) for Cloud Functions.
3. Deploy rules before app release:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage
   firebase deploy --only functions
   ```
4. Wait for composite indexes (Console → Firestore → Indexes) to reach **Enabled**.

## Android app signing

1. Create upload keystore:
   ```powershell
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. `android/key.properties` (gitignored) pointing to keystore.
3. Configure `android/app/build.gradle` signingConfigs for release.

## Versioning

- `pubspec.yaml`: `version: 1.0.0+1` — increment `+build` each Play upload.
- Tag git releases `v1.0.0`.

## Build release APK/AAB

```powershell
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Google Play Console

1. Create app **City Care Hospital Tokens** (internal name).
2. Category: Medical or Health & Fitness.
3. **Data safety** form:
   - Collects: name, phone, health-related complaint text
   - Encrypted in transit (HTTPS/TLS)
   - Users can request deletion (support email)
4. **Privacy policy URL** (required) — host hospital privacy page.
5. Content rating questionnaire.
6. Upload AAB → Internal testing → Closed → Production.

## FCM production

- Upload `google-services.json` for release package name (same as debug unless using flavors).
- No emulator calls in release builds — guard with `kReleaseMode`.

## Post-deploy monitoring

- Firebase Console → Functions logs (errors on allocateToken).
- Crashlytics (recommended): add `firebase_crashlytics` to Flutter.
- Alert on high `NO_SHOW` rate via scheduled report export.

## Rollback

- Functions: redeploy previous version from git tag.
- Rules: revert commit and `firebase deploy --only firestore:rules`.
- Play Store: halt rollout and promote previous bundle.

## Compliance (Pakistan context)

- Display hospital registration / contact on About screen.
- Urdu translations for consent and notifications where mandated by hospital policy.
- Optional: PTA-compliant SMS for OTP (Firebase Phone Auth handles carrier routing).

See [SETUP.md](SETUP.md) for initial Firebase wiring.
