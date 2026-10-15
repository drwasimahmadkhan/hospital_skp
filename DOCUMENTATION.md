# Hospital Token App — Documentation Index

Single-hospital token and appointment system. Token display format: **T-01**.

## Primary doc (all-in-one HTML)

**Open [docs/index.html](docs/index.html) in a browser** — complete guide including **Local mode (no Firebase)**.

Also see root [README.md](README.md) and [REQUIREMENTS.md](REQUIREMENTS.md).

Default backend is Local (`useMockData = true`). Firebase is optional for production.

| # | Document | Description |
|---|----------|-------------|
| ★ | [docs/index.html](docs/index.html) | **Single HTML documentation (start here)** |
| 0 | [00-QUICKSTART_DEMO.md](docs/00-QUICKSTART_DEMO.md) | 5-minute local demo walkthrough |
| — | [SETUP.md](docs/SETUP.md) | Flutter, Firebase, emulators, mock mode |
| — | [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture (Mermaid) |
| 1 | [01-FEATURES_AND_FLOWS.md](docs/01-FEATURES_AND_FLOWS.md) | Features and user flows |
| 2 | [02-DATABASE_SCHEMA.md](docs/02-DATABASE_SCHEMA.md) | Firestore collections and indexes |
| 3 | [03-PROJECT_STRUCTURE.md](docs/03-PROJECT_STRUCTURE.md) | Repo layout |
| 4 | [04-MODULES_GUIDE.md](docs/04-MODULES_GUIDE.md) | Auth, booking, queue, notifications |
| 5 | [05-CLOUD_FUNCTIONS.md](docs/05-CLOUD_FUNCTIONS.md) | Callable & scheduled functions |
| 6 | [06-SECURITY_RULES.md](docs/06-SECURITY_RULES.md) | Firestore & Storage RBAC |
| 7 | [07-TESTING_CHECKLIST.md](docs/07-TESTING_CHECKLIST.md) | QA checklist |
| 8 | [08-DEPLOYMENT_PLAY_STORE.md](docs/08-DEPLOYMENT_PLAY_STORE.md) | Deploy & Play Store |
| 9 | [09-FUTURE_ENHANCEMENTS.md](docs/09-FUTURE_ENHANCEMENTS.md) | Roadmap |
| 10 | [10-SCREENS_SPEC.md](docs/10-SCREENS_SPEC.md) | Screen specs & navigation |

## Firebase project files (repo root)

- `firebase.json` — Firestore, Storage, Functions, emulators
- `.firebaserc` — default project `hospital-token-app`
- `firestore.rules` / `firestore.indexes.json`
- `storage.rules`
- `functions/` — TypeScript Cloud Functions (v2)

## Quick deploy

```bash
cd D:\GitHub\flutter2
firebase login
firebase use hospital-token-app
cd functions && npm install && npm run build && cd ..
firebase deploy
```

See [docs/SETUP.md](docs/SETUP.md) for full setup.
