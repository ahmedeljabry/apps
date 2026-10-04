import 'package:flutter_test/flutter_test.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';

void main() {
  test('customer app ignores the legacy Firebase OTP server flag', () {
    final ConfigModel config = ConfigModel.fromJson(<String, dynamic>{
      'firebase_otp_verification': 1,
      'loyalty_point_item_purchase_point': 0,
      'ref_earning_exchange_rate': 0,
      'admin_commission': 0,
    });

    expect(config.firebaseOtpVerification, isFalse);
  });
}
