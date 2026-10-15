/// Global product defaults for a single-hospital token system.
///
/// ## Backend modes
/// - **Local (default):** `useMockData = true` — complete app, no Firebase.
///   Auth, booking, tokens, live queue, receptionist/doctor/admin all work
///   via [MockDataStore] in memory. Open `docs/index.html` for full docs.
/// - **Firebase:** set `useMockData = false`, run FlutterFire + deploy `functions/`.
class AppConstants {
  AppConstants._();

  /// Local complete backend (no Firebase). Set `false` only after Firebase is configured.
  static const bool useMockData = true;

  /// Human-readable backend label shown in settings / about.
  static String get backendLabel =>
      useMockData ? 'Local (no Firebase)' : 'Firebase';

  static const String hospitalName = 'City Care Hospital';
  static const String hospitalNameUr = 'سٹی کیئر ہسپتال';

  /// Pakistan country code (E.164 without + stored as 92xxxxxxxxxx).
  static const String countryCode = '92';
  static const String phonePrefixDisplay = '+92';

  /// Cancel / reschedule cutoff before clinic day start window.
  static const int cancelCutoffHours = 2;

  /// After Call Next, patient has this many minutes before NO_SHOW.
  static const int graceMinutes = 10;

  /// Push when patients ahead drops to this value.
  static const int nearTurnThreshold = 3;

  /// Anti-spam: max appointments a phone can create per calendar day.
  static const int maxBookingsPerPhonePerDay = 3;

  static const int otpResendSeconds = 60;
  static const int otpMaxPerHour = 5;

  /// Default average consult minutes until enough completed visits exist.
  static const int defaultAvgConsultMinutes = 12;

  static const String tokenPrefix = 'T-';

  static const String prefsLanguageKey = 'language_code';
  static const String prefsOnboardingKey = 'onboarding_done';
}