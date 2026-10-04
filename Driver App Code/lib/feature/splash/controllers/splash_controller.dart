import 'package:stackfood_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_driver/feature/splash/domain/services/splash_service_interface.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/common/models/config_model.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  final DateTime _currentTime = DateTime.now();
  DateTime get currentTime => _currentTime;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  bool _hasShownCashInHandBottomSheet = false;
  bool get hasShownCashInHandBottomSheet => _hasShownCashInHandBottomSheet;

  void setCashInHandShown(bool shown) {
    _hasShownCashInHandBottomSheet = shown;
  }

  /// The API normally returns gateway rows in active_payment_method_list.
  /// When Cash Collect is enabled, older backend deployments only return
  /// offline_payment_status and leave that list empty. Expose one safe
  /// fallback row so Pay Now remains usable and the request reaches the
  /// backend instead of being blocked by the UI.
  List<PaymentBody> get availablePaymentMethods {
    final configured = _configModel?.activePaymentMethodList ?? <PaymentBody>[];
    if (configured.isNotEmpty) return configured;
    if (_configModel?.offlinePaymentStatus == true) {
      return <PaymentBody>[
        PaymentBody(getWay: 'offline_payment', getWayTitle: 'Cash Collect'),
      ];
    }
    return <PaymentBody>[];
  }

  bool get hasPaymentMethods => availablePaymentMethods.isNotEmpty;

  Future<bool> getConfigData() async {
    ConfigModel? configModel;
    try {
      configModel = await splashServiceInterface.getConfigData().timeout(
        const Duration(seconds: 20),
      );
    } catch (_) {
      configModel = null;
    }
    bool isSuccess = false;
    if (configModel != null) {
      _configModel = configModel;

      splashServiceInterface.handleInitialTopicSubscription();
      bool isMaintenanceMode = _configModel!.maintenanceMode!;
      String platform = 'deliveryman_app';
      bool isInMaintenance =
          isMaintenanceMode &&
          _configModel!.maintenanceModeData!.maintenanceSystemSetup!.contains(
            platform,
          );

      if (isInMaintenance) {
        Get.offNamed(RouteHelper.getUpdateRoute(false));
      } else if ((Get.currentRoute.contains(RouteHelper.update) &&
              !isMaintenanceMode) ||
          (!isInMaintenance)) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } /*else {
          Get.offNamed(RouteHelper.getSignInRoute());
        }*/
      }

      isSuccess = true;
    } else {
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Future<bool> initSharedData() async {
    return await splashServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() async {
    return await splashServiceInterface.removeSharedData();
  }

  void setLanguageIntro(bool intro) {
    splashServiceInterface.setLanguageIntro(intro);
  }

  bool showLanguageIntro() {
    return splashServiceInterface.showLanguageIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  bool isRestaurantClosed() {
    DateTime open = DateFormat('hh:mm').parse('');
    DateTime close = DateFormat('hh:mm').parse('');
    DateTime openTime = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
      open.hour,
      open.minute,
    );
    DateTime closeTime = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
      close.hour,
      close.minute,
    );
    if (closeTime.isBefore(openTime)) {
      closeTime = closeTime.add(const Duration(days: 1));
    }
    if (_currentTime.isAfter(openTime) && _currentTime.isBefore(closeTime)) {
      return false;
    } else {
      return true;
    }
  }
}
