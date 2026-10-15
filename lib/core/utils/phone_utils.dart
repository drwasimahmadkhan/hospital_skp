import '../constants/app_constants.dart';

class PhoneUtils {
  PhoneUtils._();

  /// Accepts 03xxxxxxxxx, 3xxxxxxxxx, +923xxxxxxxxx, 923xxxxxxxxx
  /// Returns normalized `92XXXXXXXXXX` or null if invalid.
  static String? normalizePk(String input) {
    var digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('0') && digits.length == 11) {
      digits = AppConstants.countryCode + digits.substring(1);
    } else if (digits.length == 10 && digits.startsWith('3')) {
      digits = AppConstants.countryCode + digits;
    } else if (digits.startsWith('92') && digits.length == 12) {
      // ok
    } else {
      return null;
    }

    // Pakistan mobile: 923XXXXXXXXX (network code 3xx)
    if (!RegExp(r'^923\d{9}$').hasMatch(digits)) return null;
    return digits;
  }

  static String toE164(String normalized92) => '+$normalized92';

  static String display(String normalized92) {
    if (normalized92.length == 12) {
      return '+${normalized92.substring(0, 2)} ${normalized92.substring(2, 5)} ${normalized92.substring(5)}';
    }
    return '+$normalized92';
  }

  static bool isValidPk(String input) => normalizePk(input) != null;
}