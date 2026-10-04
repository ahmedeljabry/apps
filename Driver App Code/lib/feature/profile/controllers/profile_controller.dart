import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor_driver/common/models/response_model.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor_driver/feature/profile/domain/models/profile_model.dart';
import 'package:stackfood_multivendor_driver/feature/profile/domain/services/profile_service_interface.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/feature/profile/domain/models/record_location_body.dart';
import 'package:image_picker/image_picker.dart';

enum BiometricToggleResult {
  success,
  setupRequired,
  passwordError,
  requestError,
}

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;
  ProfileController({required this.profileServiceInterface}){
    _notification = profileServiceInterface.isNotificationActive();
  }

  ProfileModel? _profileModel;
  ProfileModel? get profileModel => _profileModel;

  bool _notification = false;
  bool get notification => _notification;

  bool _backgroundNotification = false;
  bool get backgroundNotification => _backgroundNotification;

  Timer? _timer;

  RecordLocationBody? _recordLocation;
  RecordLocationBody? get recordLocationBody => _recordLocation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  bool _shiftLoading = false;
  bool get shiftLoading => _shiftLoading;

  List<ShiftModel>? _shifts;
  List<ShiftModel>? get shifts => _shifts;

  int? _shiftId;
  int? get shiftId => _shiftId;

  List<ShiftModel> _selectedShifts = [];
  List<ShiftModel> get selectedShifts => _selectedShifts;

  Future<void> getProfile({bool canCheckPermission = true}) async {
    ProfileModel? profileModel = await profileServiceInterface.getProfileInfo();
    if (profileModel != null) {
      _selectedShifts = [];
      _profileModel = profileModel;
      _selectedShifts.addAll(profileModel.shifts??[]);
      if (_profileModel!.active == 1) {
        if(canCheckPermission) {
          profileServiceInterface.checkPermission(() => startLocationRecord());
        } else {
          startLocationRecord();
        }
      } else {
        stopLocationRecord();
      }
    }
    update();
  }

  Future<bool> updateUserInfo(ProfileModel updateUserModel, String token) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await profileServiceInterface.updateProfile(updateUserModel, _pickedFile, token);
    _isLoading = false;
    bool isSuccess;
    if (responseModel.isSuccess) {
      await getProfile();
      Get.back();
      showCustomSnackBar(responseModel.message, isError: false);
      isSuccess = true;
    } else {
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Future<bool> updateActiveStatus({bool isUpdate = false}) async {
    _shiftLoading = true;
    if(isUpdate){
      update();
    }
    ResponseModel responseModel = await profileServiceInterface.updateActiveStatus();
    bool isSuccess;
    if (responseModel.isSuccess) {
      Get.back();
      _profileModel!.active = _profileModel!.active == 0 ? 1 : 0;
      // showCustomSnackBar(responseModel.message, isError: false);
      isSuccess = true;
      if (_profileModel!.active == 1) {
        profileServiceInterface.checkPermission(() => startLocationRecord());
      } else {
        stopLocationRecord();
      }
    } else {
      isSuccess = false;
    }
    _shiftLoading = false;
    update();
    return isSuccess;
  }

  void pickImage() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    update();
  }

  bool setNotificationActive(bool isActive) {
    _notification = isActive;
    profileServiceInterface.setNotificationActive(isActive);
    update();
    return _notification;
  }

  void setBackgroundNotificationActive(bool isActive) {
    _backgroundNotification = isActive;
    update();
  }

  Future<void> removeDriver() async {
    _isLoading = true;
    update();

    ResponseModel responseModel = await profileServiceInterface.deleteDriver();
    if (responseModel.isSuccess) {
      Get.back();
      showCustomSnackBar('your_account_remove_successfully'.tr, isError: false);
      Get.find<AuthController>().clearSharedData();
      stopLocationRecord();
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }else{
      Get.back();
      showCustomSnackBar(responseModel.message, isError: true);
    }

    _isLoading = false;
    update();
  }

  Future<void> getShiftList() async {
    _shifts = null;
    _isLoading = true;
    List<ShiftModel>? shifts = await profileServiceInterface.getShiftList();
    if (shifts != null) {
      _shifts = [];
      _shifts!.addAll(shifts);
    }
    _isLoading = false;
    update();
  }

  void setShiftId(int? id){
    _shiftId = id;
    update();
  }

  void initData() {
    _pickedFile = null;
    _shiftId = null;
  }

  void startLocationRecord() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      recordLocation();
    });
  }

  void stopLocationRecord() {
    _timer?.cancel();
  }

  Future<void> recordLocation() async {
    final Position locationResult = await Geolocator.getCurrentPosition();
    String address = await profileServiceInterface.addressPlaceMark(locationResult);

    _recordLocation = RecordLocationBody(
      location: address, latitude: locationResult.latitude, longitude: locationResult.longitude,
    );

    bool isSuccess  = await profileServiceInterface.recordLocation(_recordLocation!);
    if(isSuccess) {
      debugPrint('----Added record Lat: ${_recordLocation!.latitude} Lng: ${_recordLocation!.longitude} Loc: ${_recordLocation!.location}');
    }else {
      debugPrint('----Failed record');
    }
  }

  void initShiftSelection(ProfileModel profileModel) {
    _selectedShifts = [];
    if(profileModel.shifts != null){
      for (var shift in profileModel.shifts!) {
        print('Profile Shift: ${shift.name}');
        _selectedShifts.add(shift);
      }
    }

    print('Selected Shifts: ${profileModel.shifts} // ${_selectedShifts}');
  }

  void toggleShift(ShiftModel shift) {
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

  Future<BiometricToggleResult> checkPasswordAndEnableOrDisableBiometric(String password, {required bool enable}) async {
    _isLoading = true;
    update();

    final ResponseModel? result = await profileServiceInterface.checkPassword(password);

    if (result == null) {
      _isLoading = false;
      update();
      showCustomSnackBar('something_went_wrong');
      return BiometricToggleResult.requestError;
    }

    if (result.isSuccess) {
      return await _toggleBiometric(enable);
    } else {
      showCustomSnackBar(result.message);
      _isLoading = false;
      update();
      return BiometricToggleResult.passwordError;
    }
  }


  Future<BiometricToggleResult> _toggleBiometric(bool enable) async {
    _isLoading = true;
    update();
    final AuthController authController = Get.find<AuthController>();

    if (enable) {
      final check = await authController.checkFingerprintAvailability();

      if (!check.isAvailable) {
        _isLoading = false;
        update();
        return BiometricToggleResult.setupRequired;
      }
    }

    if (_profileModel != null) {
      _profileModel!.biometricLoginStatus = enable ? 1 : 0;
      update();
    }


    final ResponseModel? result = enable ? await profileServiceInterface.enableBiometric() : await profileServiceInterface.disableBiometric();

    if (result == null) {
      if (_profileModel != null) {
        _profileModel!.biometricLoginStatus = enable ? 0 : 1;
      }
      _isLoading = false;
      update();
      showCustomSnackBar('something_went_wrong');
      return BiometricToggleResult.requestError;
    }

    if (result.isSuccess) {
      authController.setBiometric(enable);
      _isLoading = false;
      update();
      showCustomSnackBar(result.message, isError: false);
      await getProfile(canCheckPermission: false);
      return BiometricToggleResult.success;
    } else {
      if (_profileModel != null) {
        _profileModel!.biometricLoginStatus = enable ? 0 : 1;
      }
      showCustomSnackBar(result.message);
    }

    _isLoading = false;
    update();
    return BiometricToggleResult.requestError;
  }

  void triggerDelayedProfilePermissionCheck({Duration delay = const Duration(seconds: 2)}) {
    if (_profileModel?.active != 1) {
      return;
    }

    Future.delayed(delay, () {
      if (_profileModel?.active == 1) {
        profileServiceInterface.checkPermission(() => startLocationRecord());
      }
    });
  }

}
