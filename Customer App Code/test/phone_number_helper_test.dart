import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/helper/phone_number_helper.dart';

void main() {
  test('normalizes Algerian mobile numbers to the local backend format', () {
    expect(PhoneNumberHelper.normalizeLocal('06 12 34 56 78'), '0612345678');
    expect(
      PhoneNumberHelper.normalizeLocal('+213 6 12 34 56 78'),
      '0612345678',
    );
    expect(
      PhoneNumberHelper.normalizeLocal('+213 06 12 34 56 78'),
      '0612345678',
    );
    expect(PhoneNumberHelper.normalizeLocal('٠٦١٢٣٤٥٦٧٨'), '0612345678');
  });

  test('validates the supported local mobile prefixes', () {
    expect(PhoneNumberHelper.isValidLocalMobile('0551234567'), isTrue);
    expect(PhoneNumberHelper.isValidLocalMobile('0661234567'), isTrue);
    expect(PhoneNumberHelper.isValidLocalMobile('0771234567'), isTrue);
    expect(PhoneNumberHelper.isValidLocalMobile('0812345678'), isFalse);
    expect(PhoneNumberHelper.isValidLocalMobile('061234567'), isFalse);
  });

  test('converts a valid local number for Firebase only', () {
    expect(PhoneNumberHelper.toInternational('0612345678'), '+213612345678');
  });
}
