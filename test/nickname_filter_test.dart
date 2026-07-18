import 'package:flutter_test/flutter_test.dart';
import 'package:uno_family/core/utils/nickname_filter.dart';

void main() {
  group('NicknameFilter', () {
    test('accepts clean nicknames', () {
      expect(NicknameFilter.validate('magzhan'), isNull);
      expect(NicknameFilter.validate('Aru_2010'), isNull);
      expect(NicknameFilter.validate('Айсұлу'), isNull);
    });

    test('rejects too short or too long', () {
      expect(NicknameFilter.validate('ab'), isNotNull);
      expect(NicknameFilter.validate('a' * 17), isNotNull);
    });

    test('rejects phone numbers and links', () {
      expect(NicknameFilter.validate('87771234567'), isNotNull);
      expect(NicknameFilter.validate('insta_me'), isNotNull);
      expect(NicknameFilter.validate('telegram'), isNotNull);
    });

    test('rejects profanity even with digit obfuscation', () {
      expect(NicknameFilter.validate('sexyboy'), isNotNull);
      expect(NicknameFilter.validate('s3xyboy'), isNotNull);
    });

    test('rejects disallowed characters', () {
      expect(NicknameFilter.validate('hi there'), isNotNull);
      expect(NicknameFilter.validate('nick!'), isNotNull);
    });
  });
}
