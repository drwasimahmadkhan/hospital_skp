import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/shared/data/mock_data_store.dart';
import '../../features/shared/models/appointment_model.dart';
import '../../features/shared/models/department_model.dart';
import '../../features/shared/models/user_model.dart';
import '../constants/app_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main()');
});

final localeProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs)
      : super(Locale(_prefs.getString(AppConstants.prefsLanguageKey) ?? 'en'));

  final SharedPreferences _prefs;

  Future<void> setLanguage(String code) async {
    await _prefs.setString(AppConstants.prefsLanguageKey, code);
    state = Locale(code);
  }

  bool get isUrdu => state.languageCode == 'ur';
}

final authStateProvider = StateProvider<UserModel?>((ref) {
  return AppConstants.useMockData ? MockDataStore.instance.currentUser : null;
});

final departmentsProvider = Provider<List<DepartmentModel>>((ref) {
  return MockDataStore.instance.departments;
});

final myAppointmentsProvider =
    StreamProvider.family<List<AppointmentModel>, String>((ref, userId) {
  return MockDataStore.instance.watchMyAppointments(userId);
});

final onboardingDoneProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.prefsOnboardingKey) ?? false;
});