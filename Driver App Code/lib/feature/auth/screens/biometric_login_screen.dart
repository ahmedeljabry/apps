import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/app_constants.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

import '../../../common/widgets/show_finger_print_device_setup.dart';

class BiometricLoginScreen extends StatelessWidget {
  const BiometricLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(
        title: 'back_to_previous_page'.tr,
        isCenterTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Image.asset(Images.logo, width: 100),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                AppConstants.appName,
                style: robotoBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeOverLarge * 2,
                    horizontal: Dimensions.paddingSizeLarge * 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).disabledColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  child: GetBuilder<AuthController>(
                    builder: (biometricAuthController) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: Dimensions.paddingSizeOverLarge,
                          ),

                          InkWell(
                            onTap: biometricAuthController.isBiometricLoading
                                ? null
                                : () async {
                                    biometricAuthController
                                        .authenticateAndLogin(
                                          context,
                                          onNotEnrolled: () =>
                                              showFingerprintNotEnrolledSheet(
                                                context,
                                              ),
                                        );
                                  },
                            borderRadius: BorderRadius.circular(60),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).disabledColor,
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              child: Center(
                                child:
                                    biometricAuthController.isBiometricLoading
                                    ? CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : Icon(Icons.fingerprint, size: 60),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeOverLarge,
                          ),

                          Text(
                            biometricAuthController.isBiometricLoading
                                ? 'loading'.tr
                                : 'click_on_the_round_icon_to_logging_with_fingerprint'
                                      .tr,
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),

                          const SizedBox(
                            height: Dimensions.paddingSizeOverLarge,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
