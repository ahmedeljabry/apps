import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:stackfood_multivendor_driver/common/models/response_model.dart';
import 'package:stackfood_multivendor_driver/api/api_client.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor_driver/feature/profile/domain/models/record_location_body.dart';
import 'package:stackfood_multivendor_driver/feature/profile/domain/repositories/profile_repository_interface.dart';
import 'package:stackfood_multivendor_driver/util/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:stackfood_multivendor_driver/feature/profile/domain/models/profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stackfood_multivendor_driver/helper/phone_number_helper.dart';

class ProfileRepository implements ProfileRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ProfileRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<ProfileModel?> getProfileInfo() async {
    ProfileModel? profileModel;
    final String deviceID = await _getOrCreateDeviceID();
    Response response = await apiClient.getData(
      "${AppConstants.profileUri + _getUserToken()}&device_id=$deviceID",
    );
    if (response.statusCode == 200) {
      profileModel = ProfileModel.fromJson(response.body);
    }
    return profileModel;
  }

  @override
  Future<bool> recordLocation(RecordLocationBody recordLocationBody) async {
    recordLocationBody.token = _getUserToken();
    Response response = await apiClient.postData(
      AppConstants.recordLocationUri,
      recordLocationBody.toJson(),
    );
    return (response.statusCode == 200);
  }

  @override
  Future<ResponseModel?> updateProfile(
    ProfileModel userInfoModel,
    XFile? data,
    String token,
  ) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put',
      'f_name': userInfoModel.fName!,
      'l_name': userInfoModel.lName!,
      'email': userInfoModel.email!,
      'phone': PhoneNumberHelper.normalizeLocal(userInfoModel.phone),
      'shifts': jsonEncode(userInfoModel.shiftIds),
      'token': _getUserToken(),
    });
    ResponseModel? responseModel;
    Response response = await apiClient.postMultipartData(
      AppConstants.updateProfileUri,
      fields,
      [MultipartBody('image', data)],
      [],
    );
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel?> updateActiveStatus() async {
    Map<String, String> body = {};
    body['token'] = _getUserToken();
    ResponseModel? responseModel;
    Response response = await apiClient.postData(
      AppConstants.activeStatusUri,
      body,
    );
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }
    return responseModel;
  }

  @override
  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  @override
  void setNotificationActive(bool isActive) {
    if (isActive) {
      _updateToken();
    } else {
      if (!GetPlatform.isWeb) {
        apiClient.postData(AppConstants.tokenUri, {
          "_method": "put",
          "token": _getUserToken(),
          "fcm_token": '@',
        }, handleError: false);
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
        List<String>? topicList = sharedPreferences.getStringList(
          AppConstants.zoneTopic,
        );
        for (String topic in (topicList ?? [])) {
          FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        }
      }
    }
    sharedPreferences.setBool(AppConstants.notification, isActive);
  }

  @override
  Future<ResponseModel> deleteDriver() async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(
      AppConstants.driverRemove + _getUserToken(),
      {"_method": "delete"},
      handleError: false,
    );
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<List<ShiftModel>?> getShiftList() async {
    List<ShiftModel>? shifts;
    Response response = await apiClient.getData(
      '${AppConstants.shiftUri}${_getUserToken()}',
    );
    if (response.statusCode == 200) {
      shifts = [];
      response.body.forEach((shift) => shifts!.add(ShiftModel.fromJson(shift)));
    }
    return shifts;
  }

  Future<Response> _updateToken({String notificationDeviceToken = ''}) async {
    String? deviceToken;
    if (notificationDeviceToken.isEmpty) {
      if (GetPlatform.isIOS) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        NotificationSettings settings = await FirebaseMessaging.instance
            .requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
            );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          deviceToken = await _saveDeviceToken();
        }
      } else {
        if (GetPlatform.isAndroid) {
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );
        }
        deviceToken = await _saveDeviceToken();
      }
      if (!GetPlatform.isWeb) {
        _safeSubscribeToTopic(AppConstants.topic);
        List<String>? topicList = sharedPreferences.getStringList(
          AppConstants.zoneTopic,
        );
        for (String topic in (topicList ?? [])) {
          _safeSubscribeToTopic(topic);
        }

        _safeSubscribeToTopic(AppConstants.maintenanceModeTopic);
      }
    }
    return await apiClient.postData(AppConstants.tokenUri, {
      "_method": "put",
      "token": _getUserToken(),
      "fcm_token": notificationDeviceToken.isNotEmpty
          ? notificationDeviceToken
          : deviceToken,
    }, handleError: false);
  }

  void _safeSubscribeToTopic(String topic) {
    FirebaseMessaging.instance
        .subscribeToTopic(topic)
        .then(
          (_) {},
          onError: (Object error) {
            debugPrint('Topic subscription skipped: $error');
          },
        );
  }

  Future<String?> _saveDeviceToken() async {
    String? deviceToken = '';
    if (!GetPlatform.isWeb) {
      try {
        deviceToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {
        deviceToken = null;
      }
    }
    return deviceToken;
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  String _getDeviceID() {
    return sharedPreferences.getString(AppConstants.deviceID) ?? "";
  }

  Future<String> _getOrCreateDeviceID() async {
    final String savedDeviceID = _getDeviceID();
    if (savedDeviceID.isNotEmpty) {
      return savedDeviceID;
    }

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo android = await deviceInfo.androidInfo;
      await sharedPreferences.setString(AppConstants.deviceID, android.id);
      return android.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo ios = await deviceInfo.iosInfo;
      final String deviceID = ios.identifierForVendor ?? 'unknown';
      if (deviceID != 'unknown') {
        await sharedPreferences.setString(AppConstants.deviceID, deviceID);
      }
      return deviceID;
    }

    return savedDeviceID;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future get(int id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<ResponseModel?> checkPassword(String password) async {
    Map<String, String> body = {'token': _getUserToken(), 'password': password};
    ResponseModel? responseModel;
    Response response = await apiClient.postData(
      AppConstants.biometricCheckPasswordUri,
      body,
      handleError: false,
    );
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else if (response.statusCode == 403) {
      String message = response.statusText ?? 'something_went_wrong'.tr;
      if (response.body != null &&
          response.body['errors'] != null &&
          (response.body['errors'] as List).isNotEmpty) {
        message = response.body['errors'][0]['message'];
      }
      responseModel = ResponseModel(false, message);
    }
    return responseModel;
  }

  @override
  Future<dynamic> disableBiometric() async {
    final String deviceID = await _getOrCreateDeviceID();
    Map<String, String> body = {
      'token': _getUserToken(),
      'device_id': deviceID,
    };
    ResponseModel? responseModel;
    Response response = await apiClient.postData(
      AppConstants.disableBiometricUri,
      body,
      handleError: false,
    );
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    }
    // else if (response.statusCode == 403) {
    //   String message = response.statusText ?? 'something_went_wrong'.tr;
    //   if (response.body != null && response.body['errors'] != null && (response.body['errors'] as List).isNotEmpty) {
    //     message = response.body['errors'][0]['message'];
    //   }
    //   responseModel = ResponseModel(false, message);
    // }
    return responseModel;
  }

  @override
  Future<dynamic> enableBiometric() async {
    final String deviceID = await _getOrCreateDeviceID();
    Map<String, String> body = {
      'token': _getUserToken(),
      'device_id': deviceID,
    };
    ResponseModel? responseModel;
    Response response = await apiClient.postData(
      AppConstants.enableBiometricUri,
      body,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final String biometricToken = response.body['biometric_token'];
      sharedPreferences.setString(AppConstants.biometricToken, biometricToken);
      responseModel = ResponseModel(true, response.body['message']);
    }
    // else if (response.statusCode == 403) {
    //   String message = response.statusText ?? 'something_went_wrong'.tr;
    //   if (response.body != null && response.body['errors'] != null && (response.body['errors'] as List).isNotEmpty) {
    //     message = response.body['errors'][0]['message'];
    //   }
    //   responseModel = ResponseModel(false, message);
    // }
    return responseModel;
  }
}
