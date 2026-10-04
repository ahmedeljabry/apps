import 'package:country_code_picker/country_code_picker.dart';
import 'package:stackfood_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_driver/feature/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_snackbar_widget.dart';
import '../../../helper/custom_validator.dart';

class BiometricEnableLoginScreen extends StatefulWidget {
  const BiometricEnableLoginScreen({super.key});

  @override
  State<BiometricEnableLoginScreen> createState() => _BiometricEnableLoginScreenState();
}

class _BiometricEnableLoginScreenState extends State<BiometricEnableLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  String? countryDialCode;

  @override
  void initState() {
    super.initState();
    countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty
      ? Get.find<AuthController>().getUserCountryCode()
      : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: SizedBox(
          width: 1170,
          child: GetBuilder<AuthController>(builder: (authController) {
            return Column(children: [
              const SizedBox(height: 80),
              Text('please_enter_your_phone_number_and_password'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textAlign: TextAlign.center),
              const SizedBox(height: 50),

              CustomTextFieldWidget(
                hintText: 'xxx-xxx-xxxxx'.tr,
                showLabelText: false,
                controller: _phoneController,
                focusNode: _phoneFocus,
                nextFocus: _passwordFocus,
                inputType: TextInputType.phone,
                isPhone: true,
                showBorder: true,
                divider: false,
                onCountryChanged: (CountryCode countryCode) {countryDialCode = countryCode.dialCode;},
                countryDialCode: countryDialCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
              ),
              const SizedBox(height: 10),


              CustomTextFieldWidget(
                showBorder: true,
                hintText: 'eight_characters'.tr,
                showLabelText: false,
                controller: _passwordController,
                focusNode: _passwordFocus,
                inputAction: TextInputAction.done,
                inputType: TextInputType.visiblePassword,
                prefixIcon: Icons.lock,
                isPassword: true,
                onSubmit: (text) {},
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButtonWidget(
                buttonText: 'continue'.tr,
                isLoading: authController.isLoading,
                onPressed: () => _login(authController, _phoneController, _passwordController, countryDialCode!, context),
              ),
            ]);
          }),
        ),
      )),
    );
  }

  void _login(AuthController authController, TextEditingController phoneCtlr, TextEditingController passCtlr, String countryCode, BuildContext context) async {
    String phone = phoneCtlr.text.trim();
    String password = passCtlr.text.trim();

    String numberWithCountryCode = countryCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else {
      authController.login(numberWithCountryCode, password, isBiometric: true).then((status) async {
        if (status.isSuccess) {
          authController.saveUserNumberAndPassword(phone, password, countryCode);
          if (status.biometricResponse != null) {
            Get.find<AuthController>().biometricEnableSetup(status.biometricResponse!);
          } else {
            showCustomSnackBar(status.message);
          }
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }

}
