import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor_driver/feature/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String icon;
  final Function? onTap;
  final bool isSelected;
  final String title;
  final bool isOrderReq;
  const BottomNavItemWidget({
    super.key,
    required this.icon,
    this.onTap,
    this.isSelected = false,
    required this.title,
    this.isOrderReq = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        onTap: onTap as void Function()?,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomAssetImageWidget(
                    image: icon,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    height: 25,
                    width: 23,
                  ),

                  isOrderReq
                      ? PositionedDirectional(
                          top: -8,
                          end: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: GetBuilder<OrderController>(
                              builder: (orderController) {
                                return Text(
                                  orderController.latestOrderList?.length
                                          .toString() ??
                                      '0',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),

              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
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
