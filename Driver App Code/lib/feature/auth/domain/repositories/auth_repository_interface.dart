import 'package:stackfood_multivendor_driver/api/api_client.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor_driver/interface/repository_interface.dart';

abstract class AuthRepositoryInterface implements RepositoryInterface {
  Future<dynamic> login(String phone, String password);
  Future<dynamic> registerDeliveryMan(Map<String, String> data, List<MultipartBody> multiParts, List<MultipartDocument> additionalDocument);
  Future<bool> saveUserToken(String token, List<String> topic);
  Future<dynamic> updateToken({String notificationDeviceToken = ''});
  bool isLoggedIn();
  Future<bool> clearSharedData();
  Future<void> saveUserNumberAndPassword(String number, String password, String countryCode);
  String getUserNumber();
  String getUserCountryCode();
  String getUserPassword();
  Future<bool> clearUserNumberAndPassword();
  String getUserToken();
  Future<void> getDmTopic();
  Future<List<ShiftModel>?> getShiftList();
  Future<dynamic> enableBiometricLogin(String token, String deviceID);
  Future<dynamic> biometricLogin(String token, String deviceID);
  Future<bool> saveBiometricUserToken(String token);
  String getBiometricUserToken();
  Future<bool> deviceID(String deviceID);
  Future<bool> setBiometric(bool isActive);
  bool isBiometricEnabled();
}
