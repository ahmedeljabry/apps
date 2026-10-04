import 'package:cached_network_image/cached_network_image.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:flutter/cupertino.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (width != null && width!.isFinite) ? (width! * dpr).round() : null;
    final cacheHeight = (height != null && height!.isFinite) ? (height! * dpr).round() : null;

    return CachedNetworkImage(
      imageUrl: image, height: height, width: width, fit: fit,
      memCacheWidth: cacheWidth, memCacheHeight: cacheHeight,
      maxWidthDiskCache: cacheWidth, maxHeightDiskCache: cacheHeight,
      placeholder: (context, url) => CustomAssetImageWidget(image: placeholder ?? Images.placeholder, height: height, width: width, fit: fit),
      errorWidget: (context, url, error) => CustomAssetImageWidget(image: placeholder ?? Images.placeholder, height: height, width: width, fit: fit),
    );
  }
}