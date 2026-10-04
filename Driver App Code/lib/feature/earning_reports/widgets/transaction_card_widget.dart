import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor_driver/helper/price_converter_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

class OrderRow {
  final String label;
  final double value;
  const OrderRow({required this.label, required this.value});
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderId,
    required this.transactionId,
    required this.dateTime,
    required this.transactionDate,
    required this.rows,
    required this.netProfitLabel,
    required this.netProfitValue,
    this.showNetProfit = true,
    this.isIncentive = false,
  });

  final String? orderId;
  final String? transactionId;
  final String? dateTime;
  final String? transactionDate;
  final List<OrderRow> rows;
  final String netProfitLabel;
  final double netProfitValue;
  final bool showNetProfit;
  final bool isIncentive;



  @override
  Widget build(BuildContext context) {
    final allRows = [
      ...rows,
      if(showNetProfit) OrderRow(label: netProfitLabel, value: netProfitValue),
    ];
    final lastIndex = allRows.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withAlpha(50),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: robotoBlack.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                    children: [
                      if(!isIncentive && orderId != null && orderId!.isNotEmpty)
                        TextSpan(
                          text: 'order'.tr,
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200)),
                        ),
                      TextSpan(text: ' ${orderId ?? transactionId ?? ''}'),
                    ],
                  ),
                ),
                SizedBox(width: Dimensions.paddingSizeDefault,),
                Text((dateTime ?? transactionDate ?? '').tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Theme.of(context).disabledColor.withAlpha(100)),

          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: IntrinsicColumnWidth(),
              2: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: List.generate(allRows.length, (i) {
              final row = allRows[i];
              final isNetProfit = i == lastIndex;

              final labelStyle = robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200));
              final valueStyle = isNetProfit ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor) : robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200));

              final double topPad = isNetProfit ? Dimensions.paddingSizeDefault : (i == 0 ? Dimensions.paddingSizeDefault : Dimensions.fontSizeExtraSmall);

              final double bottomPad = isNetProfit ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraSmall;

              return TableRow(
                decoration: isNetProfit ? BoxDecoration(color: Theme.of(context).hintColor.withAlpha(10)) : null,
                children: [
                  // Label
                  !isIncentive && isNetProfit ? Padding(
                    padding: EdgeInsets.only(left : Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(row.label.tr, style: labelStyle),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'net_profit_tooltip'.tr,
                          preferBelow: false,
                          triggerMode: TooltipTriggerMode.tap,
                          margin: EdgeInsets.all(Dimensions.paddingSizeDefault),
                          showDuration: const Duration(seconds: 8),
                          child: CustomAssetImageWidget(
                            image: Images.noteIcon,
                            color: Theme.of(context).hintColor,
                            height: Dimensions.fontSizeSmall,
                            width: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ) : Padding(
                    padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Text(row.label.tr, style: labelStyle),
                  ),

                  // Colon
                  Padding(
                    padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Text(' : ', style: labelStyle),
                  ),

                  // Value
                  Padding(
                    padding: EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: topPad, bottom: bottomPad,),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(PriceConverter.convertPrice(row.value), style: valueStyle),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}