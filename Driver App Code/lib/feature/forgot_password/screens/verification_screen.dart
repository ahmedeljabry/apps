import 'dart:async';
import 'package:stackfood_multivendor_driver/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor_driver/feature/forgot_password/controllers/forgot_password_controller.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/helper/phone_number_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  final String? firebaseSession;
  const VerificationScreen({
    super.key,
    required this.number,
    this.firebaseSession,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    Get.find<ForgotPasswordController>().updateVerificationCode(
      '',
      canUpdate: false,
    );
    _number = PhoneNumberHelper.normalizeLocal(widget.number);
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  String maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length > 6) {
      return phoneNumber.replaceRange(
        3,
        phoneNumber.length - 2,
        '*' * (phoneNumber.length - 5),
      );
    }
    return phoneNumber;
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    double borderWidth = 0.7;
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'otp_verification'.tr),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: GetBuilder<ForgotPasswordController>(
          builder: (forgotPasswordController) {
            return Column(
              children: [
                SizedBox(height: Dimensions.paddingSizeLarge),
                CustomAssetImageWidget(
                  image: Images.otp,
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: Dimensions.paddingSizeOverLarge),

                Get.find<SplashController>().configModel!.demo!
                    ? Text('for_demo_purpose'.tr, style: robotoRegular)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'we_have_sent_a_verification_code_to'.tr,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              TextSpan(
                                text: ' ${maskPhoneNumber(_number!)}',
                                style: robotoMedium.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' ${'and_your_otp_will_be_expired_within_2min'.tr}',
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                SizedBox(height: 35),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.width > 850
                        ? 50
                        : Dimensions.paddingSizeDefault,
                  ),
                  child: MaterialPinField(
                    length: 6,
                    keyboardType: TextInputType.number,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    onChanged: forgotPasswordController.updateVerificationCode,
                    theme: MaterialPinTheme(
                      shape: MaterialPinShape.outlined,
                      cellSize: const Size(50, 60),
                      spacing: 0,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      borderWidth: borderWidth,
                      focusedBorderWidth: borderWidth,
                      fillColor: Theme.of(context).cardColor,
                      focusedFillColor: Colors.white,
                      filledFillColor: Theme.of(context).cardColor,
                      borderColor: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.6),
                      focusedBorderColor: Theme.of(context).primaryColor,
                      filledBorderColor: Theme.of(context).disabledColor,
                      entryAnimation: MaterialPinAnimation.slide,
                      animationDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.paddingSizeLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraLarge,
                  ),
                  child: CustomButtonWidget(
                    buttonText: 'verify'.tr,
                    isLoading: forgotPasswordController.verifyLoading,
                    fontColor:
                        forgotPasswordController.verificationCode.length == 6
                        ? Theme.of(context).cardColor
                        : Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed:
                        forgotPasswordController.verificationCode.length == 6
                        ? () {
                            if (widget.firebaseSession != null) {
                              forgotPasswordController
                                  .verifyFirebaseOtp(
                                    phoneNumber: _number!,
                                    session: widget.firebaseSession!,
                                    otp: forgotPasswordController
                                        .verificationCode,
                                  )
                                  .then((value) {
                                    if (value.isSuccess) {
                                      Get.toNamed(
                                        RouteHelper.getResetPasswordRoute(
                                          _number,
                                          forgotPasswordController
                                              .verificationCode,
                                          'reset-password',
                                        ),
                                      );
                                    }
                                  });
                            } else {
                              forgotPasswordController
                                  .verifyToken(_number)
                                  .then((value) {
                                    if (value.isSuccess) {
                                      Get.toNamed(
                                        RouteHelper.getResetPasswordRoute(
                                          _number,
                                          forgotPasswordController
                                              .verificationCode,
                                          'reset-password',
                                        ),
                                      );
                                    } else {
                                      showCustomSnackBar(value.message);
                                    }
                                  });
                            }
                          }
                        : null,
                  ),
                ),
                SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraLarge,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'did_not_receive_the_code'.tr,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),

                      !forgotPasswordController.isLoading
                          ? TextButton(
                              onPressed: _seconds < 1
                                  ? () async {
                                      ///Firebase OTP
                                      if (widget.firebaseSession != null) {
                                        await forgotPasswordController
                                            .firebaseVerifyPhoneNumber(
                                              _number!,
                                              canRoute: false,
                                            );
                                        _startTimer();
                                      } else {
                                        forgotPasswordController
                                            .forgotPassword(_number)
                                            .then((value) {
                                              if (value.isSuccess) {
                                                _startTimer();
                                                showCustomSnackBar(
                                                  'resend_code_successful'.tr,
                                                  isError: false,
                                                );
                                              } else {
                                                showCustomSnackBar(
                                                  value.message,
                                                );
                                              }
                                            });
                                      }
                                    }
                                  : null,
                              child: Text(
                                '${'resent'.tr}${_seconds > 0 ? ' ($_seconds)' : ''}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeLarge,
                              ),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: const CircularProgressIndicator(),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
