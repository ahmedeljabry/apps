import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/rating_bar_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_message_model.dart';
import 'package:stackfood_multivendor/features/category/domain/models/category_model.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_verified_icon_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatMetadataViewWidget extends StatelessWidget {
  final AiChatMetadata metadata;
  const AiChatMetadataViewWidget({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final List<Widget> sections = [];

    if (metadata.hasProducts) {
      sections.add(_SectionTitle(title: 'recommended_products'.tr));
      sections.add(SizedBox(
        height: 210,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(
            left: Dimensions.paddingSizeExtraSmall,
            top: Dimensions.paddingSizeExtraSmall,
            right: Dimensions.paddingSizeExtraSmall,
          ),
          itemCount: metadata.products!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return _ProductCard(product: metadata.products![index]);
          },
        ),
      ));
    }

    if (metadata.hasCategories) {
      sections.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      sections.add(_SectionTitle(title: 'categories'.tr));
      sections.add(SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: metadata.categories!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return _CategoryCard(category: metadata.categories![index]);
          },
        ),
      ));
    }

    if (metadata.hasRestaurants) {
      sections.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      sections.add(_SectionTitle(title: 'recommended_restaurants'.tr));
      sections.add(SizedBox(
        height: 215,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          itemCount: metadata.restaurants!.length,
          separatorBuilder: (_, _) => const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return _AiChatRestaurantCard(restaurant: metadata.restaurants![index]);
          },
        ),
      ));
    }

    if (metadata.hasCart) {
      final AiChatCart cart = metadata.cart!;
      sections.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      sections.add(_CartSectionTitle(title: 'in_your_cart'.tr, itemCount: cart.totalItems ?? 0));
      sections.add(_CartSection(cart: cart));
    }

    if (sections.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Text(
        title,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}

class _CartSectionTitle extends StatelessWidget {
  final String title;
  final int itemCount;
  const _CartSectionTitle({required this.title, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(children: [
        Icon(Icons.shopping_cart_outlined, size: 15, color: Theme.of(context).hintColor),
        const SizedBox(width: 4),
        Text(
          itemCount > 0 ? '$title · $itemCount ${'items'.tr}' : title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
      ]),
    );
  }
}

class _CartSection extends StatelessWidget {
  final AiChatCart cart;
  const _CartSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final bool anyStoreScrolls = cart.stores.any((g) => g.items.length > _CartStoreItemList.maxVisibleItems);
    final double maxWidth = MediaQuery.of(context).size.width * 0.78;

    final List<Widget> children = [];
    for (int i = 0; i < cart.stores.length; i++) {
      if (i != 0) {
        children.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      }
      children.add(_CartStoreGroupSection(storeGroup: cart.stores[i]));
    }
    if (cart.grandTotal != null) {
      children.add(const SizedBox(height: Dimensions.paddingSizeSmall));
      // children.add(_CartGrandTotalBar(grandTotal: cart.grandTotal!));
    }

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: GestureDetector(
        onTap: () => Get.toNamed(RouteHelper.getCartBundleListRoute()),
        child: anyStoreScrolls ? column : IntrinsicWidth(child: column),
      ),
    );
  }
}

class _CartStoreGroupSection extends StatelessWidget {
  final AiChatCartStoreGroup storeGroup;
  const _CartStoreGroupSection({required this.storeGroup});

  @override
  Widget build(BuildContext context) {
    final String storeName = storeGroup.storeName ?? '';
    final double subtotal = storeGroup.storeSubtotal ?? 0;
    final Color dividerColor = Theme.of(context).disabledColor.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
          width: 0.6,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall,
            Dimensions.paddingSizeSmall, Dimensions.paddingSizeExtraSmall,
          ),
          child: Text(
            storeName,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),

        Divider(height: 1, thickness: 1, color: dividerColor),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _CartStoreItemList(items: storeGroup.items),
        ),

        Divider(height: 1, thickness: 1, color: dividerColor),

        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [
            const Spacer(),
            Text(
              'subtotal'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              PriceConverter.convertPrice(subtotal),
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
            ),
          ]),
        ),

      ]),
    );
  }
}

class _CartStoreItemList extends StatelessWidget {
  final List<AiChatCartItem> items;
  const _CartStoreItemList({required this.items});

  static const int maxVisibleItems = 4;
  static const double _rowHeight = 56;

  @override
  Widget build(BuildContext context) {
    final bool needsScroll = items.length > maxVisibleItems;
    final Color separatorColor = Theme.of(context).disabledColor.withValues(alpha: 0.1);

    if (!needsScroll) {
      final List<Widget> rows = [];
      for (int i = 0; i < items.length; i++) {
        if (i != 0) {
          rows.add(Divider(height: Dimensions.paddingSizeSmall, thickness: 0.6, color: separatorColor));
        }
        rows.add(_CartItemRow(cartItem: items[i]));
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: rows),
      );
    }

    return SizedBox(
      height: (_rowHeight * maxVisibleItems) + (Dimensions.paddingSizeSmall * (maxVisibleItems - 1)),
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        itemCount: items.length,
        separatorBuilder: (_, _) => Divider(height: Dimensions.paddingSizeSmall, thickness: 0.6, color: separatorColor),
        itemBuilder: (context, index) => SizedBox(
          height: _rowHeight,
          child: _CartItemRow(cartItem: items[index]),
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final AiChatCartItem cartItem;
  const _CartItemRow({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final String name = cartItem.name ?? '';
    final String image = cartItem.imageFullUrl ?? '';
    final int qty = cartItem.quantity ?? 0;
    final double lineTotal = cartItem.lineTotal ?? ((cartItem.unitPrice ?? 0) * qty);
    final String variation = cartItem.variation ?? '';

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: CustomImageWidget(
          image: image, isFood: true,
          height: 40, width: 40, fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

          Text(
            name,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          Row(children: [
            if (variation.isNotEmpty) ...[
              Flexible(child: _VariationPill(variation: variation)),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            ],
            Text(
              '${'qty'.tr}: $qty',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
          ]),

        ]),
      ),

      const SizedBox(width: Dimensions.paddingSizeSmall),
      SizedBox(
        width: 70,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            PriceConverter.convertPrice(lineTotal),
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall,),
          ),
        ),
      ),
    ]);
  }
}

class _VariationPill extends StatelessWidget {
  final String variation;
  const _VariationPill({required this.variation});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: variation,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 1),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Text(
          variation,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: Theme.of(context).primaryColor,
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _CartGrandTotalBar extends StatelessWidget {
  final double grandTotal;
  const _CartGrandTotalBar({required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Text(
          'grand_total'.tr,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Spacer(),
        Text(
          PriceConverter.convertPrice(grandTotal),
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: category.id == null ? null : () => Get.toNamed(RouteHelper.getCategoryProductRoute(
        category.id, category.name ?? '',
      )),
      child: SizedBox(
        width: 90,
        child: Column(children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImageWidget(
                image: category.imageFullUrl ?? '',
                height: 60, width: 60, fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Text(
            category.name ?? '',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          ),

        ]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final double price = product.price ?? 0;
    final double discount = product.discount ?? 0;
    final String? discountType = product.discountType;
    final double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;
    final bool hasDiscount = discount > 0 && discountedPrice < price;
    final bool showVeg = Get.find<SplashController>().configModel?.toggleVegNonVeg == true && product.veg != null;
    final bool hasRating = (product.ratingCount ?? 0) > 0;
    final bool hasVariations = product.variations != null && product.variations!.isNotEmpty;

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
          width: 0.6,
        ),
      ),
      child: CustomInkWellWidget(
        radius: Dimensions.radiusDefault,
        onTap: () {
          ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
            ProductBottomSheetWidget(product: product, isCampaign: product.itemType == "campaign",),
            backgroundColor: Colors.transparent, isScrollControlled: true,
          ) : Get.dialog(
            Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: product.itemType == "campaign",)),
          );
        },
        child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: CustomImageWidget(
                image: product.imageFullUrl ?? '', isFood: true,
                height: 90, width: double.infinity, fit: BoxFit.cover,
              ),
            ),
            if (hasDiscount)
              Positioned(
                top: Dimensions.paddingSizeExtraSmall,
                left: Dimensions.paddingSizeExtraSmall,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    discountType == 'percent'
                        ? '${discount.toStringAsFixed(0)}% ${'off'.tr}'
                        : '${PriceConverter.convertPrice(discount)} ${'off'.tr}',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if ((product.restaurantName ?? '').isNotEmpty) ...[
            Text(
              product.restaurantName!,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).primaryColor,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
          ],

          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Flexible(
              child: Text(
                product.name ?? '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showVeg) ...[
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              CustomAssetImageWidget(
                product.veg == 0 ? Images.nonVegImage : Images.vegImage,
                height: 11, width: 11,
              ),
            ],
          ]),
          const SizedBox(height: 2),

          if (hasRating) ...[
            RatingBarWidget(rating: product.avgRating ?? 0, ratingCount: product.ratingCount, size: 12),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          ],

          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Flexible(
              child: Text(
                PriceConverter.convertPrice(discountedPrice),
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),

            if (hasDiscount) ...[
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Flexible(
                child: Text(
                  PriceConverter.convertPrice(price),
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

          ]),

          if (hasVariations) ...[
            const SizedBox(height: 2),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                _variationsSummary(product.variations!),
                maxLines: 1,
                softWrap: false,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ],

        ]),
      ),
      ),
    );
  }
}

/// "GroupName (value1, value2), OtherGroup (value1)" - a flat, single-line
/// summary of every variation group's options, meant to sit inside a
/// horizontally-scrolling Text rather than the app's usual selectable
/// checkbox/radio variation list (there's nothing to select here, this is
/// just a read-only preview on a recommended product card).
String _variationsSummary(List<Variation> variations) {
  final List<String> parts = [];
  for (final Variation variation in variations) {
    final String values = (variation.variationValues ?? [])
        .map((value) => value.level ?? '')
        .where((level) => level.isNotEmpty)
        .join(', ');
    final String name = variation.name ?? '';
    if (name.isEmpty && values.isEmpty) continue;
    parts.add(values.isEmpty ? name : (name.isEmpty ? values : '$name ($values)'));
  }
  return parts.join(', ');
}

class _AiChatRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const _AiChatRestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final bool isOpen = restaurant.open == 1;
    final double rating = restaurant.avgRating ?? 0;
    final int ratingCount = restaurant.ratingCount ?? 0;
    final double distanceKm = restaurant.distance ?? 0;
    final bool hasDistance = restaurant.distance != null && restaurant.distance! > 0;
    final bool freeDelivery = restaurant.freeDelivery == true;
    final String deliveryTime = restaurant.deliveryTime ?? '';

    final double discountAmount = restaurant.discount?.discount ?? 0;
    final bool isPercentDiscount = restaurant.discount?.discountType == 'percent';
    final bool hasDiscount = discountAmount > 0;
    final String discountText = hasDiscount
        ? (isPercentDiscount
            ? '${discountAmount.toStringAsFixed(0)}% ${'off'.tr}'
            : '${PriceConverter.convertPrice(discountAmount)} ${'off'.tr}')
        : '';

    final Color openColor = const Color(0xff1FA84B);
    final Color closedColor = Theme.of(context).colorScheme.error;

    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
            blurRadius: 4, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        // StackFood has no modules, so (unlike 6amMart) we can navigate straight
        // to the restaurant. Passing only id/slug lets RestaurantScreen fetch the
        // full details itself, avoiding a partial Restaurant object from metadata.
        onTap: restaurant.id == null ? null : () => Get.toNamed(
          RouteHelper.getRestaurantRoute(restaurant.id, slug: restaurant.slug),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Stack(clipBehavior: Clip.none, children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault),
              ),
              child: CustomImageWidget(
                image: restaurant.coverPhotoFullUrl ?? '', isRestaurant: true,
                height: 90, width: 230, fit: BoxFit.cover,
              ),
            ),

            if (hasDiscount)
              Positioned(
                top: Dimensions.paddingSizeExtraSmall,
                left: Dimensions.paddingSizeExtraSmall,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    discountText,
                    style: robotoMedium.copyWith(
                      color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                ),
              ),

            Positioned(
              top: Dimensions.paddingSizeExtraSmall,
              right: Dimensions.paddingSizeExtraSmall,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (isOpen ? openColor : closedColor).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  isOpen ? 'open_now'.tr : 'closed_now'.tr,
                  style: robotoMedium.copyWith(
                    color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -18, left: Dimensions.paddingSizeSmall,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                    width: 0.6,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    image: restaurant.logoFullUrl ?? '', isRestaurant: true,
                    height: 45, width: 45, fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeLarge + 2,
              Dimensions.paddingSizeSmall,
              Dimensions.paddingSizeSmall,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Flexible(
                  child: Text(
                    restaurant.name ?? '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (restaurant.verifiedSeller == true) ...[
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  const RestaurantVerifiedIconWidget(size: 14),
                ],
              ]),
              const SizedBox(height: 2),

              if(rating > 0)
                Row(children: [
                  Icon(Icons.star_rounded, size: 14, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 2),
                  Text(
                    rating > 0 ? rating.toStringAsFixed(1) : '-',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                  ),
                  if (ratingCount > 0) ...[
                    const SizedBox(width: 2),
                    Text(
                      '($ratingCount)',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              if (deliveryTime.isNotEmpty)
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 13, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deliveryTime,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              if (deliveryTime.isNotEmpty) const SizedBox(height: 2),

              if (hasDistance)
                Row(children: [
                  Icon(Icons.place_outlined, size: 13, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${distanceKm > 100 ? '100+' : distanceKm.toStringAsFixed(2)} ${'km'.tr}',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              if (hasDistance) const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              if (freeDelivery)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    'free_delivery'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

            ]),
          ),

        ]),
      ),
    );
  }
}
