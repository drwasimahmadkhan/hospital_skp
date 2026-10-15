import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_token_app/core/utils/token_utils.dart';

void main() {
  group('TokenUtils', () {
    test('formats tokens as T-01', () {
      expect(TokenUtils.format(1), 'T-01');
      expect(TokenUtils.format(12), 'T-12');
    });

    test('parses token labels', () {
      expect(TokenUtils.parse('T-07'), 7);
    });

    test('patients ahead ignores higher tokens', () {
      expect(
        TokenUtils.patientsAhead(
          myToken: 5,
          activeLowerTokens: [1, 2, 3, 8],
        ),
        3,
      );
    });

    test('estimated wait multiplies avg consult', () {
      expect(
        TokenUtils.estimatedWaitMinutes(
          patientsAhead: 4,
          avgConsultMinutes: 12,
        ),
        48,
      );
    });
  });
}