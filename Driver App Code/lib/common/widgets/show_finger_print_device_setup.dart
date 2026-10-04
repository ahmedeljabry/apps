import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/dimensions.dart';
import '../../util/styles.dart';
import 'custom_bottom_sheet_widget.dart';
import 'custom_button_widget.dart';

void showFingerprintNotEnrolledSheet(BuildContext context) {
  showCustomBottomSheet(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 60, height: 4,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        ),
        Container(width: 80, height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).disabledColor.withValues(alpha: 0.15)),
          child: const Icon(Icons.fingerprint, size: 48, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Text('please_set_up_fingerprint_on_your_device_first'.tr,
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),
        const SizedBox(height: 24),

        FutureBuilder<String>(
          future: _getBrand(),
          builder: (context, snapshot) {
            return snapshot.hasData ? Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                _getBiometricSettingsHint(snapshot.data!),
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
              ),
            ) : const SizedBox();
          },
        ),

        CustomButtonWidget(
          buttonText: 'go_to_finger_print_setting'.tr,
          onPressed: () async {
            AppSettingsType type = await _getAppSettingsType();
            Get.back();
            AppSettings.openAppSettings(type: type);
          },
        ),
        const SizedBox(height: 16),
      ]),
    ),
  );
}

Future<String> _getBrand() async {
  if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print("Brand: ${androidInfo.brand}");
    return androidInfo.brand.toLowerCase();
  }
  return 'apple';
}

Future<AppSettingsType> _getAppSettingsType() async {
  if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String brand = androidInfo.brand.toLowerCase();

    if (brand.contains('motorola') || brand.contains('lenovo') || brand.contains('xiaomi') || brand.contains('google') || brand.contains('sony')) {
      return AppSettingsType.security;
    } else if (brand.contains('samsung') || brand.contains('xiaomi') || brand.contains('vivo') || brand.contains('redmi') || brand.contains('poco') || brand.contains('oppo') || brand.contains('realme') || brand.contains('huawei') || brand.contains('honor') || brand.contains('oneplus')){
      return AppSettingsType.generalSettings;
    }
  }
  return AppSettingsType.security;
}

String _getBiometricSettingsHint(String manufacturer) {
  if (manufacturer.contains('samsung')) {
    return 'Settings → Biometrics and Security';
  } else if (manufacturer.contains('xiaomi') || manufacturer.contains('vivo') || manufacturer.contains('redmi') || manufacturer.contains('poco') || manufacturer.contains('oppo') || manufacturer.contains('realme')) {
    return '(Settings → Fingerprint, Face & Password) Or ((Settings → Security & privacy))';
  } else if (manufacturer.contains('huawei') || manufacturer.contains('honor') || manufacturer.contains('oneplus')) {
    return 'Settings → Biometrics & Password';
  } else if (manufacturer.contains('motorola') || manufacturer.contains('lenovo') || manufacturer.contains('google')) {
    return 'Settings → Security';
  } else {
    // iOS or unknown Android
    if (Platform.isIOS) {
      return 'Settings → Face ID & Passcode or Touch ID & Passcode';
    }
    return 'Settings → Security or Biometrics';
  }
}