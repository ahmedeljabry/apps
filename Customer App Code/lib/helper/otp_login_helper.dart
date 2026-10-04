import 'package:stackfood_multivendor/features/auth/domain/models/auth_response_model.dart';

class OtpLoginHelper {
  const OtpLoginHelper._();

  /// An OTP request is not a completed login until the backend returns both a
  /// verified phone and a non-empty authentication token.
  static bool requiresVerification(AuthResponseModel? response) {
    final bool hasToken = response?.token?.trim().isNotEmpty ?? false;
    final bool isPhoneVerified = response?.isPhoneVerified ?? false;
    return !hasToken || !isPhoneVerified;
  }
}
