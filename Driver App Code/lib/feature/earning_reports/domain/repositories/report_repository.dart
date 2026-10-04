import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stackfood_multivendor_driver/api/api_client.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/models/earning_report_model.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/repositories/report_repository_interface.dart';
import 'package:stackfood_multivendor_driver/util/app_constants.dart';

class EarningReportRepository implements EarningReportRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  EarningReportRepository({required this.apiClient, required this.sharedPreferences});

  String _getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  // @override
  // Future<TransactionEarningReportModel?> getTransactionEarningReportList({required int offset, required String? from, required String? to}) async {
  //   TransactionEarningReportModel? transactionEarningReportModel;
  //   Response response = await apiClient.getData('${AppConstants.transactionEarningReportUri}?limit=10&offset=$offset&filter=custom&from=$from&to=$to');
  //   if(response.statusCode == 200) {
  //     transactionEarningReportModel = TransactionEarningReportModel.fromJson(response.body);
  //   }
  //   return transactionEarningReportModel;
  // }

  @override
  Future<EarningReportModel?> getEarningReport({required int offset, required String? from, required String? to, String? type}) async {
    EarningReportModel? earningReportModel;
    final filterParam = (from != null && to != null && from.isNotEmpty && to.isNotEmpty) ? '&filter=custom&from=$from&to=$to' : '';
    final typeParam = (type != null && type.isNotEmpty) ? '&type=$type' : '';
    Response response = await apiClient.getData('${AppConstants.earningReportUri}?limit=25&offset=$offset$filterParam$typeParam&token=${_getUserToken()}');
    if(response.statusCode == 200) {
      earningReportModel = EarningReportModel.fromJson(response.body);
      log("earning report response: ${response.body}");
    }
    return earningReportModel;
  }

  // @override
  // Future<OrderEarningReportModel?> getOrderEarningReportList({required int offset, required String? from, required String? to}) async {
  //   OrderEarningReportModel? orderEarningReportModel;
  //   Response response = await apiClient.getData('${AppConstants.orderEarningReportUri}?limit=10&offset=$offset&filter=custom&from=$from&to=$to');
  //   if(response.statusCode == 200) {
  //     orderEarningReportModel = OrderEarningReportModel.fromJson(response.body);
  //   }
  //   return orderEarningReportModel;
  // }
  //
  // @override
  // Future<OrderEarningReportModel?> getCampaignEarningReportList({required int offset, required String? from, required String? to}) async {
  //   OrderEarningReportModel? campaignEarningReportModel;
  //   Response response = await apiClient.getData('${AppConstants.campaignEarningReportUri}?limit=10&offset=$offset&filter=custom&from=$from&to=$to');
  //   if(response.statusCode == 200) {
  //     campaignEarningReportModel = OrderEarningReportModel.fromJson(response.body);
  //   }
  //   return campaignEarningReportModel;
  // }
  //
  // @override
  // Future<FoodEarningReportModel?> getFoodEarningReportList({required int offset, required String? from, required String? to}) async {
  //   FoodEarningReportModel? foodEarningReportModel;
  //   Response response = await apiClient.getData('${AppConstants.foodEarningReportUri}?limit=10&offset=$offset&filter=custom&from=$from&to=$to');
  //   if(response.statusCode == 200) {
  //     foodEarningReportModel = FoodEarningReportModel.fromJson(response.body);
  //   }
  //   return foodEarningReportModel;
  // }
  //
  // @override
  // Future<Response> getTransactionEarningReportStatement({required int orderId}) async {
  //   Response response = await apiClient.getData('${AppConstants.getTransactionStatement}?order_id=$orderId');
  //   return response;
  // }
  //
  // @override
  // Future<TaxEarningReportModel?> getTaxEarningReport({required int offset, required String? from, required String? to}) async {
  //   TaxEarningReportModel? taxEarningReportModel;
  //   Response response = await apiClient.getData('${AppConstants.getTaxEarningReportUri}?limit=10&offset=$offset&from=$from&to=$to');
  //   if(response.statusCode == 200){
  //     taxEarningReportModel = TaxEarningReportModel.fromJson(response.body);
  //   }
  //   return taxEarningReportModel;
  // }
  //
  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}