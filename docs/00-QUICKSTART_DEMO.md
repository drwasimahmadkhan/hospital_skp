# 5-minute demo (no Firebase)

## Run

```powershell
cd D:\GitHub\flutter2
flutter pub get
flutter run
```

## Flows to click through

### Patient

1. Onboarding → Login  
2. Demo role: **patient** · phone `03001234567` · OTP `123456`  
3. Home → **Cardiology** → **Dr. Ahmed Khan** → **Book appointment**  
4. Pick today → **Confirm booking** → note token (e.g. `T-09`)  
5. Open **Live queue** — see *Now serving*, *Your token*, *Patients ahead*, *Est. wait*  
6. Profile → Language → **اردو** (RTL)

### Doctor (second device / hot restart)

1. Logout → Login as **doctor**  
2. Press **Call next** several times  
3. On the patient Live Queue screen, *Now serving* and *Patients ahead* update without pull-to-refresh  

### Receptionist

1. Login as **receptionist**  
2. **Book walk-in / phone** → patient enters same doctor queue  
3. Mark **Checked-in** / **Skip** / **Insert emergency**

### Admin

1. Login as **admin**  
2. View KPI cards, doctors, departments  

## What is mocked vs production

| Feature | Mock | Production |
|---------|------|------------|
| OTP | Any 4+ digits | Firebase Phone Auth + SMS |
| Token allocate | In-memory transaction-style | Cloud Function `allocateToken` |
| Live queue | Dart `StreamController` | Firestore `.snapshots()` |
| Push | In-app notification list | FCM + `notifications` collection |