import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/helper/otp_development_helper.dart';

void main() {
  group('OtpDevelopmentHelper', () {
    test(
      'bypasses the backend OTP preflight only in debug with Firebase OTP',
      () {
        expect(
          OtpDevelopmentHelper.bypassBackendPreflight(
            firebaseOtpEnabled: true,
            isDebug: true,
          ),
          isTrue,
        );
        expect(
          OtpDevelopmentHelper.bypassBackendPreflight(
            firebaseOtpEnabled: false,
            isDebug: true,
          ),
          isFalse,
        );
        expect(
          OtpDevelopmentHelper.bypassBackendPreflight(
            firebaseOtpEnabled: true,
            isDebug: false,
          ),
          isFalse,
        );
      },
    );

    test('removes resend cooldown only in debug', () {
      expect(OtpDevelopmentHelper.resendCooldownSeconds(isDebug: true), 0);
      expect(OtpDevelopmentHelper.resendCooldownSeconds(isDebug: false), 60);
    });

    test('disables Firebase app verification only in debug', () {
      expect(
        OtpDevelopmentHelper.disableFirebaseAppVerification(isDebug: true),
        isTrue,
      );
      expect(
        OtpDevelopmentHelper.disableFirebaseAppVerification(isDebug: false),
        isFalse,
      );
    });
  });
}
