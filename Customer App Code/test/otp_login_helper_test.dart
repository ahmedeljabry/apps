import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/auth_response_model.dart';
import 'package:stackfood_multivendor/helper/otp_login_helper.dart';

void main() {
  group('OtpLoginHelper.requiresVerification', () {
    test('requires OTP when the request response has no auth payload', () {
      expect(OtpLoginHelper.requiresVerification(null), isTrue);
    });

    test('requires OTP when a code was sent but no login token was issued', () {
      final response = AuthResponseModel(token: '', isPhoneVerified: true);

      expect(OtpLoginHelper.requiresVerification(response), isTrue);
    });

    test('requires OTP while the phone is not verified', () {
      final response = AuthResponseModel(
        token: 'temporary-token',
        isPhoneVerified: false,
      );

      expect(OtpLoginHelper.requiresVerification(response), isTrue);
    });

    test('does not require OTP for a completed authenticated login', () {
      final response = AuthResponseModel(
        token: 'authenticated-token',
        isPhoneVerified: true,
      );

      expect(OtpLoginHelper.requiresVerification(response), isFalse);
    });
  });
}
