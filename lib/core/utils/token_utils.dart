import '../constants/app_constants.dart';

class TokenUtils {
  TokenUtils._();

  static String format(int number) {
    final n = number.toString().padLeft(2, '0');
    return '${AppConstants.tokenPrefix}$n';
  }

  static int? parse(String label) {
    final cleaned = label.replaceAll(AppConstants.tokenPrefix, '').trim();
    return int.tryParse(cleaned);
  }

  /// Patients ahead = tokens with lower number still BOOKED/CHECKED_IN.
  static int patientsAhead({
    required int myToken,
    required Iterable<int> activeLowerTokens,
  }) {
    return activeLowerTokens.where((t) => t < myToken).length;
  }

  static int estimatedWaitMinutes({
    required int patientsAhead,
    required int avgConsultMinutes,
  }) {
    return patientsAhead * avgConsultMinutes;
  }
}