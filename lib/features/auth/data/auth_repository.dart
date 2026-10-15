import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/phone_utils.dart';
import '../../shared/data/mock_data_store.dart';
import '../../shared/models/enums.dart';
import '../../shared/models/patient_model.dart';
import '../../shared/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  final _mock = MockDataStore.instance;

  UserModel? get currentUser =>
      AppConstants.useMockData ? _mock.currentUser : null;

  /// Mock OTP: any code with length >= 4 works in demo mode.
  Future<void> sendOtp(String phoneInput) async {
    final normalized = PhoneUtils.normalizePk(phoneInput);
    if (normalized == null) {
      throw ArgumentError('Invalid Pakistan mobile number');
    }
    if (AppConstants.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return;
    }
    throw UnimplementedError('Configure Firebase Auth for production OTP');
  }

  Future<UserModel> verifyOtp({
    required String phoneInput,
    required String otp,
    UserRole demoRole = UserRole.patient,
  }) async {
    final normalized = PhoneUtils.normalizePk(phoneInput);
    if (normalized == null) throw ArgumentError('Invalid phone');
    if (otp.length < 4) throw ArgumentError('Invalid OTP');

    if (AppConstants.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _mock.loginAsRole(demoRole);
      return _mock.currentUser!;
    }
    throw UnimplementedError('Configure Firebase Auth for production OTP');
  }

  Future<void> logout() async {
    if (AppConstants.useMockData) {
      _mock.logout();
    }
  }

  Future<void> completeProfile({
    required String name,
    required int age,
    required Gender gender,
  }) async {
    if (!AppConstants.useMockData) return;
    final u = _mock.currentUser;
    if (u == null) return;
    _mock.currentUser = u.copyWith(displayName: name);
    final existing = _mock.currentPatient;
    _mock.currentPatient = PatientModel(
      id: existing?.id ?? 'pat_${u.id}',
      userId: u.id,
      name: name,
      phone: u.phone,
      age: age,
      gender: gender,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
  }
}