import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/services/auth_service_interface.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/api/api_client.dart';
import 'package:stackfood_multivendor_driver/common/models/config_model.dart';
import 'package:stackfood_multivendor_driver/common/models/response_model.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/vehicle_model.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../profile/controllers/profile_controller.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}) {
    _biometric = authServiceInterface.isBiometricEnabled();
  }

  bool _biometric = true;
  bool get biometric => _biometric;

  void setBiometric(bool isActive) {
    _biometric = isActive;
    authServiceInterface.setBiometric(isActive);
    update();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  List<XFile> _pickedIdentities = [];
  List<XFile> get pickedIdentities => _pickedIdentities;

  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  List<String> get identityTypeList => _identityTypeList;

  int _identityTypeIndex = 0;
  int get identityTypeIndex => _identityTypeIndex;

  final List<String?> _dmTypeList = ['freelancer', 'salary_based'];
  List<String?> get dmTypeList => _dmTypeList;

  int _dmTypeIndex = -1;
  int get dmTypeIndex => _dmTypeIndex;

  List<VehicleModel>? _vehicles;
  List<VehicleModel>? get vehicles => _vehicles;

  List<int?>? _vehicleIds;
  List<int?>? get vehicleIds => _vehicleIds;

  int? _vehicleIndex = 0;
  int? get vehicleIndex => _vehicleIndex;

  double _dmStatus = 0.4;
  double get dmStatus => _dmStatus;

  bool _showPassView = false;
  bool get showPassView => _showPassView;

  bool _lengthCheck = false;
  bool get lengthCheck => _lengthCheck;

  bool _numberCheck = false;
  bool get numberCheck => _numberCheck;

  bool _uppercaseCheck = false;
  bool get uppercaseCheck => _uppercaseCheck;

  bool _lowercaseCheck = false;
  bool get lowercaseCheck => _lowercaseCheck;

  bool _spatialCheck = false;
  bool get spatialCheck => _spatialCheck;

  List<Data>? _dataList;
  List<Data>? get dataList => _dataList;

  List<dynamic>? _additionalList;
  List<dynamic>? get additionalList => _additionalList;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  List<ShiftModel>? _shifts;
  List<ShiftModel>? get shifts => _shifts;

  final List<ShiftModel> _selectedShifts = [];
  List<ShiftModel> get selectedShifts => _selectedShifts;

  void setJoinUsPageData({bool isUpdate = true}){
    _dataList = authServiceInterface.processDataList(Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData);
    _additionalList = authServiceInterface.processAdditionalDataList(Get.find<SplashController>().configModel!.deliverymanAdditionalJoinUsPageData);
    if(isUpdate) {
      update();
    }
  }

  void setAdditionalDate(int index, String date) {
    _additionalList![index] = date;
    update();
  }

  void setAdditionalCheckData(int index, int i, String date) {
    if(_additionalList![index][i] == date){
      _additionalList![index][i] = 0;
    } else {
      _additionalList![index][i] = date;
    }
    update();
  }

  Future<void> pickFile(int index, MediaData mediaData) async {
    FilePickerResult? result = await authServiceInterface.picFile(mediaData);
    if(result != null) {
      _additionalList![index].add(result);
    }
    update();
  }

  void removeAdditionalFile(int index, int subIndex) {
    _additionalList![index].removeAt(subIndex);
    update();
  }

  void showHidePass({bool isUpdate = true}){
    _showPassView = ! _showPassView;
    if(isUpdate) {
      update();
    }
  }

  Future<ResponseModel> login(String phone, String password, {bool isBiometric = false}) async {
    _isLoading = true;
    update();
    Response response = await authServiceInterface.login(phone, password);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if (isBiometric) {
        responseModel = ResponseModel(true, 'successful', biometricResponse: response);
      } else {
        authServiceInterface.saveUserToken(response);
        await authServiceInterface.updateToken();
        responseModel = ResponseModel(true, 'successful');
      }
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authServiceInterface.clearSharedData();
  }

  void saveUserNumberAndPassword(String number, String password, String countryCode) {
    authServiceInterface.saveUserNumberAndPassword(number, password, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  void setDMTypeIndex(int? dmType, bool notify) {
    _dmTypeIndex = dmType!;
    if(notify) {
      update();
    }
  }

  void removeDmImage(){
    _pickedImage = null;
    update();
  }

  void setIdentityTypeIndex(String? identityType, bool notify) {
    int index0 = 0;
    for(int index=0; index<_identityTypeList.length; index++) {
      if(_identityTypeList[index] == identityType) {
        index0 = index;
        break;
      }
    }
    _identityTypeIndex = index0;
    if(notify) {
      update();
    }
  }

  String camelToSentence(String text) {
    var result = text.replaceAll('_', " ");
    var finalResult = result[0].toUpperCase() + result.substring(1);
    return finalResult;
  }

  void pickDmImageForRegistration(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    }else {
      if (isLogo) {
        _pickedImage = await authServiceInterface.pickImageFromGallery();
      } else {
        XFile? pickedIdentities = await authServiceInterface.pickImageFromGallery();
        if(pickedIdentities != null) {
          _pickedIdentities.add(pickedIdentities);
        }
      }
      update();
    }
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  Future<void> registerDeliveryMan(Map<String, String> data, List<FilePickerResult> additionalDocuments, List<String> inputTypeList) async {
    _isLoading = true;
    update();

    List<MultipartBody> multiParts = authServiceInterface.prepareMultiPartsBody(_pickedImage, _pickedIdentities);
    List<MultipartDocument> multiPartsDocuments = authServiceInterface.prepareMultipartDocuments(inputTypeList, additionalDocuments);

    bool isSuccess = await authServiceInterface.registerDeliveryMan(data, multiParts, multiPartsDocuments);
    if (isSuccess) {
      Get.offAllNamed(RouteHelper.getSignInRoute());
      showCustomSnackBar('delivery_man_registration_successful'.tr, isError: false);
    }
    _isLoading = false;
    update();
  }

  Future<void> getVehicleList() async {
    _vehicleIds = null;
    List<VehicleModel>? vehicles = await authServiceInterface.getVehicleList();
    if (vehicles != null) {
      _vehicles = [];
      _vehicles!.addAll(vehicles);
      _vehicleIds = authServiceInterface.vehicleIds(vehicles);
    }
    update();
  }

  void setVehicleIndex(int? index, bool notify) {
    _vehicleIndex = index;
    if(notify) {
      update();
    }
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))){
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      update();
    }
  }

  void dmStatusChange(double value, {bool isUpdate = true}){
    _dmStatus = value;
    if(isUpdate) {
      update();
    }
  }

  String camelCaseToSentence(String text) {
    var result = text.replaceAll('_', " ");
    var finalResult = result[0].toUpperCase() + result.substring(1);
    return finalResult;
  }

  Future<void> updateAndTopicSubscrive() async {
    await authServiceInterface.updateAndTopicSubscrive();
  }

  Future<void> getShiftList() async {
    _isLoading = true;
    List<ShiftModel>? shifts = await authServiceInterface.getShiftList();
    if (shifts != null) {
      _shifts = shifts;
    }
    _isLoading = false;
    update();
  }

  void toggleShift(ShiftModel shift) {
    if (_dmTypeIndex == 1) {return;}
    if (_selectedShifts.any((deliveryManShift) => deliveryManShift.id == shift.id)) {
      _selectedShifts.removeWhere((deliveryManShift) => deliveryManShift.id == shift.id);
    } else {
      _selectedShifts.add(shift);
    }
    update();
  }

  void removeShift(ShiftModel shift) {
    _selectedShifts.removeWhere((deliveryManShift) => deliveryManShift.id == shift.id);
    update();
  }

  bool isShiftSelected(ShiftModel shift) {
    return _selectedShifts.any((deliveryManShift) => deliveryManShift.id == shift.id);
  }

  List<int> getSelectedShiftIds() {
    return _selectedShifts.map((shift) => shift.id!).toList();
  }

  /// Biometric Auth section ----->
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isBiometricLoading = false;
  bool get isBiometricLoading => _isBiometricLoading;

  Future<bool> _isDeviceSupported() => _auth.isDeviceSupported();
  Future<bool> isDeviceSupported() => _isDeviceSupported();

  Future<List<BiometricType>> _getAvailableBiometrics() => _auth.getAvailableBiometrics();

  String getBiometricToken() => authServiceInterface.getBiometricUserToken();

  Future<void> biometricEnableSetup(Response response) async {
    _isBiometricLoading = true;
    update();

    final bool authenticated = await _deviceBiometricAuthentication('Scan your fingerprint to enable biometric login');
    if (!authenticated) {
      _isBiometricLoading = false;
      update();
      showCustomSnackBar('Fingerprint not recognized. Please try again.');
      return;
    }

    final String deviceID = await _getDeviceID();
    final biometricToken = await enableBiometric(response.body['token'], deviceID);

    if (biometricToken != null) {
      authServiceInterface.saveUserToken(response);
      await authServiceInterface.updateToken();
      await Get.find<ProfileController>().getProfile();
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
    _isBiometricLoading = false; update();
  }

  Future<void> authenticateAndLogin(BuildContext context, {VoidCallback? onNotEnrolled}) async {
    final check = await checkFingerprintAvailability();
    if (!check.isAvailable) {
      onNotEnrolled?.call();
      return;
    }

    final String savedToken = getBiometricToken();

    if (savedToken.isEmpty) {
      Get.toNamed(RouteHelper.getBiometricFingerPrintLoginRoute());
      return;
    }

    _isBiometricLoading = true;
    update();

    final bool authenticated = await _deviceBiometricAuthentication('Scan your fingerprint to sign in');
    if (!authenticated) {
      _isBiometricLoading = false;
      update();
      return;
    }

    final String deviceID = await _getDeviceID();
    final ResponseModel status = await _biometricLogin(savedToken, deviceID);

    if (status.isSuccess) {
      await Get.find<ProfileController>().getProfile();
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      showCustomSnackBar(status.message);
    }

    _isBiometricLoading = false;
    update();
  }

  Future<String> _getDeviceID() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo android = await deviceInfo.androidInfo;
      authServiceInterface.savedDeviceID(android.id);
      return android.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo ios = await deviceInfo.iosInfo;
      authServiceInterface.savedDeviceID(ios.identifierForVendor!);
      return ios.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  Future<BiometricCheckResult> checkFingerprintAvailability() async {
    try {
      final biometrics = await _getAvailableBiometrics();
      final hasFingerprint = biometrics.contains(BiometricType.fingerprint) || biometrics.contains(BiometricType.strong);
      if (!hasFingerprint) {
        return BiometricCheckResult(isAvailable: false, reason: 'Fingerprint not available.');
      }

      return BiometricCheckResult(isAvailable: true, reason: 'Fingerprint ready.');
    } on PlatformException catch (e) {
      return BiometricCheckResult(isAvailable: false, reason: 'Platform error: ${e.message}');
    } catch (e) {
      return BiometricCheckResult(isAvailable: false, reason: 'Error: $e');
    }
  }

  Future<String?> enableBiometric(String token, String deviceID) async {
    _isBiometricLoading = true;
    update();
    Response response = await authServiceInterface.enableBiometricLogin(token, deviceID);
    if (response.statusCode == 200) {
      final String biometricToken = response.body['biometric_token'];
      authServiceInterface.saveBiometricUserToken(biometricToken);
      return biometricToken;
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isBiometricLoading = false;
    update();
    return null;
  }

  Future<ResponseModel> _biometricLogin(String token, String deviceID) async {
    _isBiometricLoading = true;
    update();
    Response response = await authServiceInterface.biometricLogin(token, deviceID);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      authServiceInterface.saveUserToken(response);
      await authServiceInterface.updateToken();
      responseModel = ResponseModel(true, 'successful');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isBiometricLoading = false;
    update();
    return responseModel;
  }

  Future<bool> _deviceBiometricAuthentication(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException catch (e) {
      showCustomSnackBar('Authentication error: ${e.message}');
      return false;
    } catch (_) {
      return false;
    }
  }
}

class BiometricCheckResult {
  BiometricCheckResult({required this.isAvailable, required this.reason});

  final bool isAvailable;
  final String reason;
}