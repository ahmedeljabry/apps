part of '../screens/earning_report_screen.dart';

class _EarningCardWidget extends StatelessWidget {
  final Color cardColor;
  final String icon;
  final Color iconColor;
  final String title;
  final double amount;
  final List<Map<String,dynamic>>? data;
  final String? profitText;
  final bool isIncentiveTab;
  const _EarningCardWidget({required this.cardColor, required this.icon, required this.iconColor, required this.title, this.data, this.profitText, required this.amount, this.isIncentiveTab = false});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredData = data?.where((item) => (item['value'] ?? 0) != 0).toList() ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeExtraSmall)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(PriceConverter.convertPrice(amount), style: robotoSemiBold.copyWith(color: iconColor, fontSize: Dimensions.fontSizeLarge)),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
            ),
            child: CustomAssetImageWidget(image: icon,height: 30,width: 30)
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        if(filteredData.isNotEmpty) SizedBox(
          height: 45,
          child: Builder(
            builder: (context) {
              return ListView.builder(
                itemCount: filteredData.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    margin: EdgeInsets.only(right: index == filteredData.length - 1 ? 0 : Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Theme.of(context).hintColor.withValues(alpha: 0.3) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        '${filteredData[index]['label']}'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                      ),
                      SizedBox(width: Dimensions.paddingSizeLarge),
                      Text(PriceConverter.convertPrice(
                        (filteredData[index]['value'] is double || filteredData[index]['value'] is int)
                            ? filteredData[index]['value'].toDouble()
                            : double.tryParse(filteredData[index]['value']?.toString() ?? '0') ?? 0.0,
                      )),
                    ]),
                  );
                },
              );
            }
          ),
        ),

        if(profitText != null)  Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Theme.of(context).hintColor.withValues(alpha: 0.3) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(
            children: [
              CustomAssetImageWidget(image: Images.noteIcon, height: 12, width: 12, color: iconColor,),
              SizedBox(width: Dimensions.paddingSizeSmall,),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    profitText!,
                    maxLines: 1,
                    style: robotoMedium.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}


