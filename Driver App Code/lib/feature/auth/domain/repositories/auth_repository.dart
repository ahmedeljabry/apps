import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor_driver/api/api_client.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/vehicle_model.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/repositories/auth_repository_interface.dart';
import 'package:stackfood_multivendor_driver/util/app_constants.dart';
import 'package:stackfood_multivendor_driver/helper/phone_number_helper.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  bool _tokenRefreshListenerAttached = false;
  AuthRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Response> login(String phone, String password) async {
    return await apiClient.postData(AppConstants.loginUri, {
      "phone": PhoneNumberHelper.normalizeLocal(phone),
      "password": password,
    }, handleError: false);
  }

  @override
  Future<bool> registerDeliveryMan(
    Map<String, String> data,
    List<MultipartBody> multiParts,
    List<MultipartDocument> additionalDocument,
  ) async {
    if (data['phone'] != null) {
      data['phone'] = PhoneNumberHelper.normalizeLocal(data['phone']);
    }
    Response response = await apiClient.postMultipartData(
      AppConstants.dmRegisterUri,
      data,
      multiParts,
      additionalDocument,
    );
    return (response.statusCode == 200);
  }

  @override
  Future<List<VehicleModel>?> getList() async {
    List<VehicleModel>? vehicles;
    Response response = await apiClient.getData(AppConstants.vehiclesUri);
    if (response.statusCode == 200) {
      vehicles = [];
      response.body.forEach(
        (vehicle) => vehicles!.add(VehicleModel.fromJson(vehicle)),
      );
    }
    return vehicles;
  }

  @override
  Future<bool> saveUserToken(String token, List<String> topic) async {
    apiClient.token = token;
    apiClient.updateHeader(
      token,
      sharedPreferences.getString(AppConstants.languageCode),
    );
    sharedPreferences.setStringList(AppConstants.zoneTopic, topic);
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  @override
  Future<Response> updateToken({String notificationDeviceToken = ''}) async {
    _ensureTokenRefreshListener();
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
        deviceToken = await _saveDeviceToken();
      }
      if (!GetPlatform.isWeb) {
        List<String> topics =
            sharedPreferences.getStringList(AppConstants.zoneTopic) ?? [];
        for (String topic in topics) {
          FirebaseMessaging.instance.subscribeToTopic(topic);
        }
        FirebaseMessaging.instance.subscribeToTopic(
          AppConstants.maintenanceModeTopic,
        );
      }
    }
    return await apiClient.postData(AppConstants.tokenUri, {
      "_method": "put",
      "token": getUserToken(),
      "fcm_token": notificationDeviceToken.isNotEmpty
          ? notificationDeviceToken
          : deviceToken,
    }, handleError: false);
  }

  void _ensureTokenRefreshListener() {
    if (_tokenRefreshListenerAttached || GetPlatform.isWeb) return;
    _tokenRefreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      if (isLoggedIn() && token.isNotEmpty) {
        try {
          await updateToken(notificationDeviceToken: token);
        } catch (error) {
          // FCM can rotate before APNS/Android registration is complete.
          // The next refresh/login will retry synchronization.
        }
      }
    });
  }

  @override
  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.token);
  }

  @override
  Future<bool> clearSharedData() async {
    if (!GetPlatform.isWeb) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      List<String> topics =
          sharedPreferences.getStringList(AppConstants.zoneTopic) ?? [];
      for (String topic in topics) {
        FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
      apiClient.postData(AppConstants.tokenUri, {
        "_method": "put",
        "token": getUserToken(),
        "fcm_token": '@',
      }, handleError: false);
    }
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.setStringList(AppConstants.ignoreList, []);
    await sharedPreferences.remove(AppConstants.userAddress);
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.remove(AppConstants.userNumber);
    await sharedPreferences.remove(AppConstants.userCountryCode);
    await clearUserNumberAndPassword();
    apiClient.updateHeader(null, null);
    return true;
  }

  @override
  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  ) async {
    try {
      await sharedPreferences.setString(AppConstants.userPassword, password);
      await sharedPreferences.setString(
        AppConstants.userNumber,
        PhoneNumberHelper.normalizeLocal(number),
      );
      await sharedPreferences.setString(
        AppConstants.userCountryCode,
        countryCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  @override
  String getUserCountryCode() {
    return sharedPreferences.getString(AppConstants.userCountryCode) ?? "";
  }

  @override
  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.userPassword) ?? "";
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.remove(AppConstants.userCountryCode);
    return await sharedPreferences.remove(AppConstants.userNumber);
  }

  @override
  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
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

  @override
  Future<void> getDmTopic() async {
    Response response = await apiClient.getData(
      '${AppConstants.dmTopicUri}${_getUserToken()}',
    );
    if (response.statusCode == 200) {
      List<String> responseTopics = [];
      response.body['topic'].forEach((topic) {
        responseTopics.add(topic.toString());
      });
      if (responseTopics.isNotEmpty) {
        List<String> topics =
            sharedPreferences.getStringList(AppConstants.zoneTopic) ?? [];
        for (String topic in topics) {
          print('----unsubscribe topic: $topic');
          FirebaseMessaging.instance.unsubscribeFromTopic(topic);
        }
        sharedPreferences.setStringList(AppConstants.zoneTopic, responseTopics);
        for (String topic in responseTopics) {
          print('----subscribe topic: $topic');
          FirebaseMessaging.instance.subscribeToTopic(topic);
        }
      }
    }
  }

  @override
  Future<List<ShiftModel>?> getShiftList() async {
    List<ShiftModel>? shifts;
    Response response = await apiClient.getData(AppConstants.shiftsUri);
    if (response.statusCode == 200) {
      shifts = [];
      response.body.forEach((shift) => shifts!.add(ShiftModel.fromJson(shift)));
    }
    return shifts;
  }

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
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
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<Response> enableBiometricLogin(String token, String deviceID) async {
    return await apiClient.postData(AppConstants.enableBiometricUri, {
      "token": token,
      "device_id": deviceID,
    }, handleError: false);
  }

  @override
  Future<Response> biometricLogin(String token, String deviceID) async {
    return await apiClient.postData(AppConstants.biometricLoginUri, {
      "biometric_token": token,
      "device_id": deviceID,
    }, handleError: false);
  }

  @override
  Future<bool> saveBiometricUserToken(String token) async {
    return await sharedPreferences.setString(
      AppConstants.biometricToken,
      token,
    );
  }

  @override
  String getBiometricUserToken() {
    return sharedPreferences.getString(AppConstants.biometricToken) ?? "";
  }

  @override
  Future<bool> deviceID(String deviceID) async {
    return await sharedPreferences.setString(AppConstants.deviceID, deviceID);
  }

  @override
  Future<bool> setBiometric(bool isActive) async {
    return await sharedPreferences.setBool(AppConstants.biometric, isActive);
  }

  @override
  bool isBiometricEnabled() {
    return sharedPreferences.getBool(AppConstants.biometric) ?? true;
  }
}
