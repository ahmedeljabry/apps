import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifiedSellerWidget extends StatelessWidget {
  final bool isVerified;
  final double size;
  const VerifiedSellerWidget({super.key, required this.isVerified, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return isVerified
        ? Tooltip(
            message: 'verified_restaurant'.tr,
            preferBelow: false,
            triggerMode: TooltipTriggerMode.tap,
            child: Icon(Icons.verified, color: const Color(0xFF1DA1F2), size: size),
          )
        : const SizedBox();
  }
}
