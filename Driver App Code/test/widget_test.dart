import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor_driver/helper/phone_number_helper.dart';

void main() {
  test('driver app uses the local Algerian phone contract', () {
    expect(PhoneNumberHelper.normalizeLocal('+213612345678'), '0612345678');
    expect(PhoneNumberHelper.isValidLocalMobile('0612345678'), isTrue);
  });
}
