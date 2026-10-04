import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatSuggestionChipsWidget extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;
  const AiChatSuggestionChipsWidget({super.key, required this.onSuggestionTap});

  // StackFood is a food-only app (no modules), so the suggestions are always the
  // food set — unlike 6amMart which switched suggestions per active module.
  List<String> get _suggestions => [
    'ai_suggestion_show_food'.tr, 'ai_ion_find_popular'.tr,
    'ai_suggestion_dinner'.tr, 'ai_suggestion_cheese_pizza'.tr,
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> suggestions = _suggestions;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Align(
        alignment: Get.find<LocalizationController>().isLtr ? Alignment.centerLeft : Alignment.centerRight,
        child: Text(
          '${'try_asking'.tr}:',
          style: robotoMedium.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault),
        ),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Wrap(
        spacing: Dimensions.paddingSizeSmall,
        runSpacing: Dimensions.paddingSizeSmall,
        alignment: WrapAlignment.center,
        children: suggestions.map((text) => _SuggestionChip(
          text: text,
          onTap: () => onSuggestionTap(text),
        )).toList(),
      ),

    ]);
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome_outlined, size: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            text,
            style: robotoMedium.copyWith(
              fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeExtraSmall : Dimensions.fontSizeSmall,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ]),
      ),
    );
  }
}
