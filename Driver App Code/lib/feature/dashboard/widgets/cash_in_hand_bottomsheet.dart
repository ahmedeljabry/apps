import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor_driver/feature/my_account/widgets/payment_method_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor_driver/feature/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/helper/price_converter_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

class CashInHandBottomSheet extends StatelessWidget {
  const CashInHandBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    print(
      '===1=profile api call from dashboard: ${Get.find<SplashController>().configModel!.minAmountToPayDm!} > ${Get.find<ProfileController>().profileModel?.payableBalance!} // earning: ${Get.find<ProfileController>().profileModel?.earnings}',
    );

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: Dimensions.paddingSizeSmall,
            left: Dimensions.paddingSizeLarge,
            right: Dimensions.paddingSizeLarge,
            bottom: Dimensions.paddingSizeLarge,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusExtraLarge),
              topRight: Radius.circular(Dimensions.radiusExtraLarge),
            ),
          ),
          child: GetBuilder<ProfileController>(
            builder: (profileController) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).disabledColor.withValues(alpha: 0.3),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeLarge,
                    ),
                    child: Column(
                      children: [
                        Image.asset(Images.realMoney, height: 70),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        Text(
                          'total_cash_in_hand'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          PriceConverter.convertPrice(
                            profileController.profileModel?.payableBalance ?? 0,
                          ),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Text(
                    'please_pay_the_admin_payable_amount_to_successfully_complete_and_close_the_settlement'
                        .tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeOverLarge),

                  CustomButtonWidget(
                    buttonText:
                        '${'pay_now'.tr} (${PriceConverter.convertPrice(profileController.profileModel?.payableBalance ?? 0)})',
                    onPressed: () {
                      final splashController = Get.find<SplashController>();
                      if (!splashController.hasPaymentMethods ||
                          splashController.configModel?.digitalPayment !=
                              true) {
                        showCustomSnackBar(
                          'currently_there_are_no_payment_options_available_please_contact_admin_regarding_any_payment_process_or_queries'
                              .tr,
                        );
                      } else {
                        Get.back();
                        showCustomBottomSheet(
                          child: const PaymentMethodBottomSheetWidget(),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),

        Positioned(
          right: -5,
          top: -5,
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.clear_rounded,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
      ],
    );
  }
}
