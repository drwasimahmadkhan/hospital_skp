import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_token_app/core/utils/phone_utils.dart';

void main() {
  group('PhoneUtils', () {
    test('normalizes 03xxxxxxxxx', () {
      expect(PhoneUtils.normalizePk('03001234567'), '923001234567');
    });

    test('normalizes +92', () {
      expect(PhoneUtils.normalizePk('+92 300 1234567'), '923001234567');
    });

    test('rejects invalid', () {
      expect(PhoneUtils.normalizePk('0211234567'), isNull);
    });
  });
}