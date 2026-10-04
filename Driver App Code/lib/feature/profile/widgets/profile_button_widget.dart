import 'package:flutter/cupertino.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_card.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/custom_asset_image_widget.dart';

class ProfileButtonWidget extends StatelessWidget {
  final String? assetIcon;
  final IconData? icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  const ProfileButtonWidget({super.key, required this.icon, required this.title, required this.onTap, this.isButtonActive, this.assetIcon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: CustomCard(
        isBorder: false,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: isButtonActive != null ? 8 : Dimensions.paddingSizeDefault,
        ),
        child: Row(children: [

          if(icon != null) Icon(icon, size: 25, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
          if(assetIcon != null)  CustomAssetImageWidget(
            image: assetIcon!,
            height: 25, width: 25,
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text(title, style: robotoRegular)),

          isButtonActive != null ? CupertinoSwitch(
            value: isButtonActive!,
            onChanged: (bool isActive) => onTap(),
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
          ) : const SizedBox(),

        ]),
      ),
    );
  }
}