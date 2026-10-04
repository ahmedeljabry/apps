import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/controllers/report_controller.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/widgets/transaction_card_widget.dart';
import 'package:stackfood_multivendor_driver/helper/price_converter_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/images.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

import '../domain/emun/filter_type.dart';
import '../domain/models/earning_report_model.dart';
part '../widgets/earning_card_widget.dart';

class EarningReportScreen extends StatefulWidget {
  const EarningReportScreen({super.key});

  @override
  State<EarningReportScreen> createState() => _EarningReportScreenState();
}

class _EarningReportScreenState extends State<EarningReportScreen> {
  final ScrollController scrollController = ScrollController();
  final ValueNotifier selectedTransactionNotifier  = ValueNotifier(0);
  final Color earningColor = Color(0xFF04BB7B);
  final Color expenseColor = Color(0xFFE6A832);
  final Color profitColor = Color(0xFF245BD1);

  @override
  void initState() {
    super.initState();

    Get.find<EarningReportController>().setOffset(1);
    Get.find<EarningReportController>().initSetDate();
    Get.find<EarningReportController>().getEarningReport(offset: '1', from: Get.find<EarningReportController>().from, to: Get.find<EarningReportController>().to,);

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<EarningReportController>().transactions != null && !Get.find<EarningReportController>().isLoading) {
        int pageSize = (Get.find<EarningReportController>().pageSize! / 10).ceil();
        if (Get.find<EarningReportController>().offset < pageSize) {
          Get.find<EarningReportController>().showBottomLoader();
          Get.find<EarningReportController>().getEarningReport(
            offset: (Get.find<EarningReportController>().offset + 1).toString(),
            from: Get.find<EarningReportController>().from,
            to: Get.find<EarningReportController>().to,
            type: selectedTransactionNotifier.value == 1 ? 'incentive' : null,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EarningReportController>(builder: (reportController) {
      return Scaffold(
        appBar: CustomAppBarWidget(
          title: 'earning_report'.tr,
          actionWidget: PopupMenuButton(
            position: PopupMenuPosition.under,
            itemBuilder: (context) {
              return <PopupMenuEntry>[
                PopupMenuItem(
                  value: FilterType.all,
                  child: SizedBox(width: 100, child: Text('all_the_time'.tr, style: robotoRegular)),
                ),

                PopupMenuItem(
                  value: FilterType.thisYear,
                  child: Text('this_year'.tr, style: robotoRegular),
                ),

                PopupMenuItem(
                  value: FilterType.previousYear,
                  child: Text('previous_year'.tr, style: robotoRegular),
                ),

                PopupMenuItem(
                  value: FilterType.thisMonth,
                  child: Text('this_month'.tr, style: robotoRegular),
                ),

                PopupMenuItem(
                  value: FilterType.thisWeek,
                  child: Text('this_week'.tr, style: robotoRegular),
                ),

                PopupMenuItem(
                  value: FilterType.custom,
                  child: Text('custom'.tr, style: robotoRegular),
                ),

              ];
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
              ),
              child: Stack(clipBehavior: Clip.none, children: [
                Icon(Icons.tune_rounded, color: Theme.of(context).colorScheme.secondary, size: 20),
                if(reportController.selectedFilterType != FilterType.all)
                  Positioned(
                    top: -2, right: -2,
                    child: Container(
                      height: 10, width: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                      ),
                    ),
                  ),
              ]),
            ),
            onSelected: (dynamic value) {
              if (value == FilterType.all) {
                reportController.setFilter(FilterType.all.name, isEarningReport : true);
              }else if (value == FilterType.thisYear) {
                reportController.setFilter(FilterType.thisYear.name, isEarningReport : true);
              }else if (value == FilterType.previousYear) {
                reportController.setFilter(FilterType.previousYear.name, isEarningReport : true);
              }else if (value == FilterType.thisMonth) {
                reportController.setFilter(FilterType.thisMonth.name, isEarningReport : true);
              }else if (value == FilterType.thisWeek) {
                reportController.setFilter(FilterType.thisWeek.name, isEarningReport : true);
              } else{
                reportController.showDatePicker(context, isEarningReport: true);
              }
            },
          ),
        ),

        // note: remove from here static condition
        body:  SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [

            Column(children: [
              /// total earning
              ValueListenableBuilder(
                valueListenable: selectedTransactionNotifier,
                builder: (context, selectedIndex, child) {
                  return _EarningCardWidget(
                    cardColor: earningColor.withAlpha(50),
                    icon: Images.dollerIcon,
                    iconColor: earningColor,
                    title: '${'total_earnings'.tr} (${'with_admin_commission'.tr})',
                    amount: reportController.getEarningReportModel?.summary?.totalEarnings?.toDouble() ?? 0.0,
                    data: reportController.getEarningData(),
                    isIncentiveTab: selectedIndex == 1,
                  );
                }
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

              ValueListenableBuilder(
                valueListenable: selectedTransactionNotifier,
                builder: (context, selectedIndex, child) {
                  return Row(children: [
                    /// Total Expenses
                    Expanded(child: _EarningCardWidget(
                      cardColor: expenseColor.withAlpha(50),
                      icon: Images.dollerIcon,
                      iconColor: expenseColor,
                      title: 'commission_paid'.tr,
                      amount: reportController.getEarningReportModel?.summary?.totalExpenses?.toDouble() ?? 0.0,
                    )),
                    const SizedBox(width: Dimensions.paddingSizeDefault,),

                    if((reportController.getEarningReportModel?.summary?.netProfit ?? 0) != 0)
                      Expanded(child: _EarningCardWidget(
                        cardColor: profitColor.withAlpha(50),
                        icon: Images.walletIconSign,
                        iconColor: profitColor,
                        title: 'net_income'.tr,
                        amount: reportController.getEarningReportModel?.summary?.netProfit?.toDouble() ?? 0.0,
                      )),
                  ]);
                }
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

              /// Transactions and Incentive Tabs
              ValueListenableBuilder(
                valueListenable: selectedTransactionNotifier,
                builder: (context, selectedIndex, child) {
                  List<TransactionData>? list = reportController.transactions;
                  if(selectedIndex == 0 && list != null) {
                    list = list.where((txn) => (txn.deliveryCharge ?? 0) != 0 || (txn.incentive ?? 0) != 0 || (txn.tips ?? 0) != 0 || (txn.commissionPaid ?? 0) != 0 || (txn.netProfit ?? 0) != 0).toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(children: [
                        _TabButton(
                          title: 'transactions'.tr,
                          isSelected: selectedIndex == 0,
                          onTap: () {
                            selectedTransactionNotifier.value = 0;
                            reportController.getEarningReport(offset: '1', from: reportController.from, to: reportController.to, type: null);
                          },
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        _TabButton(
                          title: 'incentive'.tr,
                          isSelected: selectedIndex == 1,
                          onTap: () {
                            selectedTransactionNotifier.value = 1;
                            reportController.getEarningReport(offset: '1', from: reportController.from, to: reportController.to, type: 'incentive');
                          },
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      reportController.transactions == null ?
                      const Center(child: Padding(
                        padding: EdgeInsets.only(top: Dimensions.paddingSizeOverLarge),
                        child: CircularProgressIndicator(),
                      ))
                      : (list!.isEmpty) ?
                        Padding(padding: EdgeInsets.only(top: context.height * 0.2),
                          child: Center(child: Text(
                            selectedIndex == 0 ? 'no_transaction_found'.tr : 'no_incentive_found'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6),
                            ),
                          )),
                        ) : ListView.builder(
                          itemCount: list.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final txn = list![index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: OrderCard(
                                orderId: txn.orderId,
                                transactionId: txn.transactionId,
                                dateTime: txn.date,
                                transactionDate: txn.transactionDate,
                                rows: [
                                  if (selectedIndex == 0) ...[
                                    if ((txn.deliveryCharge ?? 0) > 0)
                                      OrderRow(label: 'delivery_charge', value: txn.deliveryCharge!),
                                    if ((txn.incentive ?? 0) > 0)
                                      OrderRow(label: 'incentive', value: txn.incentive!),
                                    if ((txn.tips ?? 0) > 0)
                                      OrderRow(label: 'tips', value: txn.tips!),
                                    if ((txn.commissionPaid ?? 0) > 0)
                                      OrderRow(label: 'commission_paid', value: txn.commissionPaid!),
                                  ] else ...[
                                    OrderRow(label: 'incentive', value: txn.incentive ?? 0),
                                  ],
                                ],
                                netProfitLabel: 'net_profit',
                                netProfitValue: txn.netProfit ?? 0,
                                showNetProfit: selectedIndex == 0,
                                isIncentive: selectedIndex == 1,
                              ),
                            );
                          },
                        ),

                      if (reportController.isLoading && reportController.transactions != null && selectedIndex == 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                        ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],
                  );
                }
              ),
            ]),

          ]),
        ),
      );
    });
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  const _TabButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(),
        child: Column(children: [
          Text(title, style: isSelected ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor) : robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
        ]),
      ),
    );
  }
}
