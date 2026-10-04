import 'package:stackfood_multivendor_driver/helper/phone_number_helper.dart';

class CustomValidator {
  static Future<PhoneValid> isPhoneValid(String number) async {
    final String phone = PhoneNumberHelper.normalizeLocal(number);
    final bool isValid = PhoneNumberHelper.isValidLocalMobile(phone);
    return PhoneValid(
      isValid: isValid,
      countryCode: PhoneNumberHelper.countryDialCode.substring(1),
      phone: isValid ? phone : '',
    );
  }
}

class PhoneValid {
  bool isValid;
  String countryCode;
  String phone;
  PhoneValid({
    required this.isValid,
    required this.countryCode,
    required this.phone,
  });
}
