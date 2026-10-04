import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/repositories/report_repository_interface.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/services/report_service_interface.dart';

class EarningReportService implements EarningReportServiceInterface {
  final EarningReportRepositoryInterface earningReportRepositoryInterface;
  EarningReportService({required this.earningReportRepositoryInterface});

  // @override
  // Future<TransactionEarningReportModel?> getTransactionEarningReportList({required int offset, required String? from, required String? to}) async {
  //   return await reportRepositoryInterface.getTransactionEarningReportList(offset: offset, from: from, to: to);
  // }

  @override
  Future<dynamic> getEarningReport({required int offset, required String? from, required String? to, String? type}) async {
    return await earningReportRepositoryInterface.getEarningReport(
      offset: offset,
      from: from,
      to: to,
      type: type,
    );
  }

  // @override
  // Future<OrderEarningReportModel?> getOrderEarningReportList({required int offset, required String? from, required String? to}) async {
  //   return await earningReportRepositoryInterface.getOrderEarningReportList(offset: offset, from: from, to: to);
  // }
  //
  // @override
  // Future<OrderEarningReportModel?> getCampaignEarningReportList({required int offset, required String? from, required String? to}) async {
  //   return await earningReportRepositoryInterface.getCampaignEarningReportList(offset: offset, from: from, to: to);
  // }
  //
  // @override
  // Future<FoodEarningReportModel?> getFoodEarningReportList({required int offset, required String? from, required String? to}) async {
  //   return await earningReportRepositoryInterface.getFoodEarningReportList(offset: offset, from: from, to: to);
  // }
  //
  // @override
  // Future<Response> getTransactionEarningReportStatement({required int orderId}) async {
  //   return await earningReportRepositoryInterface.getTransactionEarningReportStatement(orderId: orderId);
  // }
  //
  // @override
  // Future<TaxEarningReportModel?> getTaxEarningReport({required int offset, required String? from, required String? to}) async {
  //   return await earningReportRepositoryInterface.getTaxEarningReport(offset: offset, from: from, to: to);
  // }

}