import 'package:stackfood_multivendor_driver/interface/repository_interface.dart';

abstract class EarningReportRepositoryInterface implements RepositoryInterface{
  // Future<dynamic> getTransactionEarningReportList({required int offset, required String? from, required String? to});
  Future<dynamic> getEarningReport({required int offset, required String? from, required String? to, String? type});
  // Future<dynamic> getOrderEarningReportList({required int offset, required String? from, required String? to});
  // Future<dynamic> getCampaignEarningReportList({required int offset, required String? from, required String? to});
  // Future<dynamic> getFoodEarningReportList({required int offset, required String? from, required String? to});
  // Future<Response> getTransactionEarningReportStatement({required int orderId});
  // Future<TaxEarningReportModel?> getTaxEarningReport({required int offset, required String? from, required String? to});
}