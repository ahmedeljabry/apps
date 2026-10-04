import 'package:flutter/foundation.dart';

class OtpDevelopmentHelper {
  static bool bypassBackendPreflight({
    required bool firebaseOtpEnabled,
    bool isDebug = kDebugMode,
  }) {
    return isDebug && firebaseOtpEnabled;
  }

  static int resendCooldownSeconds({bool isDebug = kDebugMode}) {
    return isDebug ? 0 : 60;
  }

  static bool disableFirebaseAppVerification({bool isDebug = kDebugMode}) {
    return isDebug;
  }
}
