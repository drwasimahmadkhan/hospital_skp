import 'package:flutter/material.dart';

/// Lightweight localizations (mirrors ARB keys; run `flutter gen-l10n` to regenerate).
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ur'),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const _en = {
    'appTitle': 'Hospital Token',
    'welcome': 'Welcome',
    'login': 'Login',
    'phoneHint': '3XX XXXXXXX',
    'sendOtp': 'Send OTP',
    'verifyOtp': 'Verify OTP',
    'otpHint': 'Enter 6-digit code',
    'completeProfile': 'Complete profile',
    'fullName': 'Full name',
    'home': 'Home',
    'departments': 'Departments',
    'doctors': 'Doctors',
    'bookAppointment': 'Book appointment',
    'myAppointments': 'My appointments',
    'liveQueue': 'Live queue',
    'profile': 'Profile',
    'settings': 'Settings',
    'language': 'Language',
    'notifications': 'Notifications',
    'feedback': 'Feedback',
    'patientsAhead': 'Patients ahead',
    'estimatedWait': 'Estimated wait',
    'minutes': 'minutes',
    'reconnecting': 'Reconnecting to live queue…',
    'checkIn': 'Check in',
    'callNext': 'Call next',
    'completeVisit': 'Complete',
    'skipToken': 'Skip',
    'pauseQueue': 'Pause',
    'leaveQueue': 'Leave for today',
    'receptionDashboard': 'Reception',
    'doctorDashboard': 'Doctor desk',
    'noUpcoming': 'No upcoming appointment',
    'confirmBooking': 'Confirm booking',
    'logout': 'Log out',
  };

  static const _ur = {
    'appTitle': 'ہسپتال ٹوکن',
    'welcome': 'خوش آمدید',
    'login': 'لاگ ان',
    'phoneHint': '3XX XXXXXXX',
    'sendOtp': 'OTP بھیجیں',
    'verifyOtp': 'OTP تصدیق',
    'otpHint': '6 ہندسوں کا کوڈ',
    'completeProfile': 'پروفائل مکمل کریں',
    'fullName': 'مکمل نام',
    'home': 'ہوم',
    'departments': 'شعبہ جات',
    'doctors': 'ڈاکٹرز',
    'bookAppointment': 'اپائنٹمنٹ بک کریں',
    'myAppointments': 'میری اپائنٹمنٹس',
    'liveQueue': 'لائیو قطار',
    'profile': 'پروفائل',
    'settings': 'ترتیبات',
    'language': 'زبان',
    'notifications': 'اطلاعات',
    'feedback': 'رائے',
    'patientsAhead': 'آگے مریض',
    'estimatedWait': 'تخمینی انتظار',
    'minutes': 'منٹ',
    'reconnecting': 'لائیو قطار سے دوبارہ منسلک…',
    'checkIn': 'چیک ان',
    'callNext': 'اگلا بلائیں',
    'completeVisit': 'مکمل',
    'skipToken': 'چھوڑیں',
    'pauseQueue': 'روکیں',
    'leaveQueue': 'آج کے لیے چھوڑ دیں',
    'receptionDashboard': 'ریسیپشن',
    'doctorDashboard': 'ڈاکٹر ڈesk',
    'noUpcoming': 'کوئی آنے والی اپائنٹمنٹ نہیں',
    'confirmBooking': 'بoking کی تصدیق',
    'logout': 'لاگ آؤٹ',
  };

  Map<String, String> get _map =>
      locale.languageCode == 'ur' ? _ur : _en;

  String get appTitle => _map['appTitle']!;
  String get welcome => _map['welcome']!;
  String get login => _map['login']!;
  String get phoneHint => _map['phoneHint']!;
  String get sendOtp => _map['sendOtp']!;
  String get verifyOtp => _map['verifyOtp']!;
  String get otpHint => _map['otpHint']!;
  String get completeProfile => _map['completeProfile']!;
  String get fullName => _map['fullName']!;
  String get home => _map['home']!;
  String get departments => _map['departments']!;
  String get doctors => _map['doctors']!;
  String get bookAppointment => _map['bookAppointment']!;
  String get myAppointments => _map['myAppointments']!;
  String get liveQueue => _map['liveQueue']!;
  String get profile => _map['profile']!;
  String get settings => _map['settings']!;
  String get language => _map['language']!;
  String get notifications => _map['notifications']!;
  String get feedback => _map['feedback']!;
  String get patientsAhead => _map['patientsAhead']!;
  String get estimatedWait => _map['estimatedWait']!;
  String get minutes => _map['minutes']!;
  String get reconnecting => _map['reconnecting']!;
  String get checkIn => _map['checkIn']!;
  String get callNext => _map['callNext']!;
  String get completeVisit => _map['completeVisit']!;
  String get skipToken => _map['skipToken']!;
  String get pauseQueue => _map['pauseQueue']!;
  String get leaveQueue => _map['leaveQueue']!;
  String get receptionDashboard => _map['receptionDashboard']!;
  String get doctorDashboard => _map['doctorDashboard']!;
  String get noUpcoming => _map['noUpcoming']!;
  String get confirmBooking => _map['confirmBooking']!;
  String get logout => _map['logout']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ur'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
