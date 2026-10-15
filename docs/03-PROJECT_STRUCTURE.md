# Project Structure

Actual layout of this repository:

```
flutter2/
├── README.md
├── DOCUMENTATION.md              # Doc index
├── pubspec.yaml
├── analysis_options.yaml
├── l10n.yaml
├── firebase.json
├── .firebaserc
├── firestore.rules
├── firestore.indexes.json
├── storage.rules
├── docs/                         # Full product & engineering docs
├── scripts/seed_demo_notes.md
├── test/                         # Unit tests (phone, token)
├── android/                      # Android host
├── ios/                          # iOS host (scaffold)
├── functions/                    # Cloud Functions (TypeScript)
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts
│       ├── tokens/allocateToken.ts
│       ├── queue/                # callNext, updateStatus, graceNoShow
│       ├── notifications/        # triggers + reminders
│       ├── admin/reports.ts
│       └── utils/
└── lib/
    ├── main.dart
    ├── app.dart
    ├── l10n/                     # en + ur ARB
    ├── core/
    │   ├── constants/app_constants.dart   # useMockData, cutoffs
    │   ├── theme/app_theme.dart
    │   ├── router/app_router.dart
    │   ├── providers/
    │   ├── firebase/
    │   ├── utils/                # phone, token, dates
    │   └── widgets/
    └── features/
        ├── shared/
        │   ├── models/           # User, Doctor, Appointment, QueueState…
        │   └── data/mock_data_store.dart
        ├── auth/                 # splash, onboarding, login, OTP
        ├── home/
        ├── doctors/
        ├── booking/              # date/capacity + confirmation
        ├── appointments/
        ├── queue/                # LIVE queue screen + logic
        ├── profile/              # family, language settings
        ├── notifications/
        ├── feedback/
        ├── receptionist/
        ├── doctor/
        └── admin/
```

## Conventions

| Area | Rule |
|------|------|
| Mock vs prod | `AppConstants.useMockData` switches repositories |
| Token label | `TokenUtils.format` → `T-01` (prod also stores `tokenLabel` from CF) |
| Queue doc id | `{doctorId}_{yyyy-MM-dd}` |
| Roles | `patient` \| `receptionist` \| `doctor` \| `admin` |
| State | Riverpod |
| Navigation | go_router |

## Related

- [00-QUICKSTART_DEMO.md](00-QUICKSTART_DEMO.md)
- [04-MODULES_GUIDE.md](04-MODULES_GUIDE.md)
- [05-CLOUD_FUNCTIONS.md](05-CLOUD_FUNCTIONS.md)
