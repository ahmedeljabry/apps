import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor_driver/common/models/config_model.dart';

void main() {
  test('always uses backend OTP even when the server advertises Firebase', () {
    final ConfigModel config = ConfigModel.fromJson(<String, dynamic>{
      'firebase_otp_verification': 1,
      'is_sms_active': true,
    });

    expect(config.firebaseOtpVerification, isFalse);
    expect(config.toJson()['firebase_otp_verification'], isFalse);
  });
}
