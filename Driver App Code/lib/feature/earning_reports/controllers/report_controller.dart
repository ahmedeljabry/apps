import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/models/earning_report_model.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/models/report_model.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/models/tax_report_model.dart';
import 'package:stackfood_multivendor_driver/feature/earning_reports/domain/services/report_service_interface.dart';
import 'package:stackfood_multivendor_driver/helper/date_converter_helper.dart';

import '../domain/emun/filter_type.dart';

class EarningReportController extends GetxController implements GetxService {
  final EarningReportServiceInterface earningReportServiceInterface;
  EarningReportController({required this.earningReportServiceInterface});

  int? _pageSize;
  int? get pageSize => _pageSize;

  List<String> _offsetList = [];

  int _offset = 1;
  int get offset => _offset;

  FilterType _selectedFilterType = FilterType.all;
  FilterType get selectedFilterType => _selectedFilterType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double? _onHold;
  double? get onHold => _onHold;

  double? _canceled;
  double? get canceled => _canceled;

  double? _completedTransactions;
  double? get completedTransactions => _completedTransactions;

  List<OrderTransactions>? _orderTransactions;
  List<OrderTransactions>? get orderTransactions => _orderTransactions;

  late DateTimeRange _selectedDateRange;

  String? _from;
  String? get from => _from;

  String? _to;
  String? get to => _to;

  OtherData? _otherData;
  OtherData? get otherData => _otherData;

  List<Orders>? _orders;
  List<Orders>? get orders => _orders;

  List<String>? _label;
  List<String>? get label => _label;

  List<double>? _earning;
  List<double>? get earning => _earning;

  String? _type;
  String? get type => _type;

  double? _earningAvg;
  double? get earningAvg => _earningAvg;

  List<Foods>? _foods;
  List<Foods>? get foods => _foods;

  String? _avgType;
  String? get avgType => _avgType;

  // TaxReportModel? _taxReportModel;
  // TaxReportModel? get taxReportModel => _taxReportModel;
  //
  List<OrdersModel>? _orderList;
  List<OrdersModel>? get orderList => _orderList;

  bool _setCustom = false;
  bool get setCustom => _setCustom;

  EarningReportModel? _earningReportModel;
  EarningReportModel? get getEarningReportModel => _earningReportModel;

  List<TransactionData>? _transactions;
  List<TransactionData>? get transactions => _transactions;


  void initSetDate() {
    _from = DateConverter.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 10000)));
    _to = DateConverter.dateTimeForCoupon(DateTime.now());
    _setCustom = false;
    _selectedFilterType = FilterType.all;
  }

  void initTaxReportDate(){
    // _from = DateConverter.dateTimeForTax(DateTime.now().subtract(const Duration(days: 10000)));
    // _to = _toDateConverter.dateTimeForTax(DateTime.now());
    _setCustom = false;
  }

  Future<void> getTransactionReportList({required String offset, required String? from, required String? to}) async {

    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _orderTransactions = null;
      update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      TransactionReportModel? transactionReport;
      // = await reportServiceInterfaceServiceInterface.getTransactionReportList(offset: int.parse(offset), from: from, to: to);
      if (transactionReport != null) {
        TransactionReportModel transactionReportModel = transactionReport;
        _onHold = transactionReportModel.onHold;
        _canceled = transactionReportModel.canceled;
        _completedTransactions = transactionReportModel.completedTransactions;
        if (offset == '1') {
          _orderTransactions = [];
        }
        _orderTransactions!.addAll(transactionReportModel.orderTransactions!);
        _pageSize = transactionReportModel.totalSize;
        _isLoading = false;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }


  bool get hasMoreData => _transactions != null && _pageSize != null && _transactions!.length < _pageSize!;

  Future<void> getEarningReport({
    required String offset,
    required String? from,
    required String? to,
    String? type,
  }) async {
    _type = type;
    from = _convertDateFormat(from ?? '');
    to = _convertDateFormat(to ?? '');

    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _transactions = null;
      _earningReportModel = null;
      _isLoading = true;
      update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      _isLoading = true;
      update();

      EarningReportModel? model = await earningReportServiceInterface.getEarningReport(
        offset: int.parse(offset),
        from: from,
        to: to,
        type: type,
      );

      if (model != null) {
        _earningReportModel = model;
        if (offset == '1') _transactions = [];
        if (model.transactions?.data != null) {
          _transactions!.addAll(model.transactions!.data!);
        }
        _pageSize = model.transactions?.totalSize;
        _offset = int.parse(offset);
      }

      _isLoading = false;
      update();
    } else {
      if (_isLoading) {
        _isLoading = false;
        update();
      }
    }
  }


  getEarningData(){
    return [
      {
        'label': "delivery_charge",
        'value' : getEarningReportModel?.summary?.breakdown?.deliveryCharge ?? 0.0,
      },
      {
        'label': "total_tips",
        'value' : getEarningReportModel?.summary?.breakdown?.dmTips ?? 0.0,
      },
      {
        'label': "total_incentives",
        'value' : getEarningReportModel?.summary?.breakdown?.incentives ?? 0.0,
      },
      {
        'label': "admin_commission",
        'value' : getEarningReportModel?.summary?.breakdown?.adminCommission ?? 0.0,
      },
    ];
  }

  Future<void> getOrderReportList({required String offset, required String? from, required String? to}) async {

    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _orders = null;
      update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      OrderReportModel? orderReport;
      // = await reportServiceInterface.getOrderReportList(offset: int.parse(offset), from: from, to: to);
      if (orderReport != null) {
        OrderReportModel orderReportModel = orderReport;
        _otherData = orderReportModel.otherData;
        if (offset == '1') {
          _orders = [];
        }
        _orders!.addAll(orderReportModel.orders!);
        _pageSize = orderReportModel.totalSize;
        _isLoading = false;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> getCampaignReportList({required String offset, required String? from, required String? to}) async {

    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _orders = null;
      update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      OrderReportModel? campaignReport;
      // = await reportServiceInterface.getCampaignReportList(offset: int.parse(offset), from: from, to: to);
      if (campaignReport != null) {
        OrderReportModel campaignReportModel = campaignReport;
        if (offset == '1') {
          _orders = [];
        }
        _orders!.addAll(campaignReportModel.orders!);
        _pageSize = campaignReportModel.totalSize;
        _isLoading = false;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> getFoodReportList({required String offset, required String? from, required String? to}) async {

    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _label = null;
      _earning = null;
      _earningAvg = null;
      _foods = null;
      update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      FoodReportModel? foodReport;
      // = await reportServiceInterface.getFoodReportList(offset: int.parse(offset), from: from, to: to);
      if (foodReport != null) {
        FoodReportModel foodReportModel = foodReport;
        if (offset == '1') {
          _label = [];
          _earning = [];
          _earningAvg = null;
          _foods = [];
        }
        _label!.addAll(foodReportModel.label!);
        _earning!.addAll(foodReportModel.earning!);
        _earningAvg = foodReportModel.earningAvg!;
        _avgType = foodReportModel.avgType!;
        _foods!.addAll(foodReportModel.foods!);
        _pageSize = foodReportModel.totalSize;

        _isLoading = false;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  // Future<void> getTaxReport({required String offset, required String? from, required String? to}) async {
  //
  //   if(offset == '1') {
  //     _offsetList = [];
  //     _offset = 1;
  //     _orders = null;
  //     update();
  //   }
  //   if (!_offsetList.contains(offset)) {
  //     _offsetList.add(offset);
  //
  //     TaxReportModel? taxReportModel;
  //     // = await reportServiceInterface.getTaxReport(offset: int.parse(offset), from: from, to: to);
  //     if (taxReportModel != null) {
  //       if (offset == '1') {
  //         _orderList = [];
  //       }
  //       _taxReportModel = taxReportModel;
  //       _orderList!.addAll(taxReportModel.orders!);
  //       _pageSize = taxReportModel.totalSize;
  //       _isLoading = false;
  //       update();
  //     }
  //   }else {
  //     if(isLoading) {
  //       _isLoading = false;
  //       update();
  //     }
  //   }
  // }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void showDatePicker(BuildContext context, {bool transaction = false, bool order = false, bool campaign = false, bool isTaxReport = false, bool isEarningReport = false}) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'done'.tr,
      confirmText: 'done'.tr,
      cancelText: 'cancel'.tr,
      fieldStartLabelText: 'start_date'.tr,
      fieldEndLabelText: 'end_date'.tr,
      errorInvalidRangeText: 'select_range'.tr,
    );

    if (result != null) {
      _selectedDateRange = result;
      _setCustom = true;
      _selectedFilterType = FilterType.custom;

      if(isTaxReport){
        // _from = DateConverter.dateTimeForTax(_selectedDateRange.start);
        // _to = DateConverter.dateTimeForTax(_selectedDateRange.end);
      }else{
        _from = _selectedDateRange.start.toString().split(' ')[0];
        _to = _selectedDateRange.end.toString().split(' ')[0];
      }
      update();

      if(isTaxReport){
        // getTaxReport(offset: '1', from: _from, to: _to);
      }else if(transaction){
        getTransactionReportList(offset: '1', from: _from, to: _to);
      }else if(order){
        getOrderReportList(offset: '1', from: _from, to: _to);
      } else if(campaign) {
        getCampaignReportList(offset: '1', from: _from, to: _to);
      } else if(isEarningReport){
        getEarningReport(offset: '1', from: _from, to: _to, type: _type);
      } else{
        getFoodReportList(offset: '1', from: _from, to: _to);
      }

    }
  }

  void setFilter(String filterText, {bool transaction = false, bool order = false, bool campaign = false, bool isTaxReport = false, bool isEarningReport = false}) {
    if(filterText == FilterType.all.name){
      _from = DateConverter.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 10000)));
      _to = DateConverter.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    }else if(filterText == FilterType.thisYear.name){
      _from = DateConverter.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 365)));
      _to = DateConverter.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    }else if(filterText == FilterType.previousYear.name){
      DateTime now = DateTime.now();
      _from = DateConverter.dateTimeForCoupon(DateTime(now.year -1, 1, 1));
      _to = DateConverter.dateTimeForCoupon(DateTime(now.year -1, 12, 31));
      _setCustom = false;
    }else if(filterText == FilterType.thisMonth.name){
      DateTime now = DateTime.now();
      _from = DateConverter.dateTimeForCoupon(DateTime(now.year, now.month, 1));
      _to = DateConverter.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    }else if(filterText == FilterType.thisWeek.name){
      DateTime now = DateTime.now();
      int currentWeekday = now.weekday;
      _from = DateConverter.dateTimeForCoupon(now.subtract(Duration(days: currentWeekday - 1)));
      _to = DateConverter.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    }

    for (FilterType type in FilterType.values) {
      if (type.name == filterText) {
        _selectedFilterType = type;
        break;
      }
    }

    if(isTaxReport){
      // getTaxReport(offset: '1', from: _from, to: _to);
    }else if(transaction){
      getTransactionReportList(offset: '1', from: _from, to: _to);
    }else if(order){
      getOrderReportList(offset: '1', from: _from, to: _to);
    } else if(campaign) {
      getCampaignReportList(offset: '1', from: _from, to: _to);
    }else if(isEarningReport){
      getEarningReport(offset: '1', from: _from, to: _to, type: _type);
    } else{
      getFoodReportList(offset: '1', from: _from, to: _to);
    }
  }

  // Future<void> getTransactionReportStatement(int orderId) async {
  //   _isLoading = true;
  //   update();
  //
  //   Response response = await reportServiceInterface.getTransactionReportStatement(orderId: orderId);
  //   if (response.statusCode == 200) {
  //     downloadPdf(response.body['file_url'], orderId);
  //   } else {
  //     showCustomSnackBar('download_failed'.tr);
  //   }
  //   _isLoading = false;
  //   update();
  // }

  // Future<void> downloadPdf(String url, int orderId) async {
  //   try {
  //     // Request storage permission
  //     var status = await Permission.storage.request();
  //
  //     if (status.isGranted) {
  //       var response = await http.get(Uri.parse(url));
  //
  //       if (response.statusCode == 200) {
  //         Directory directory = await PdfDownloadHelper.getProjectDirectory(Get.find<SplashController>().configModel?.businessName ?? AppConstants.appName);
  //         String fileName = 'Report $orderId.pdf';
  //         String filePath = '${directory.path}/$fileName';
  //
  //         // Write the file to the directory
  //         File file = File(filePath);
  //         await file.writeAsBytes(response.bodyBytes);
  //
  //         String relativePath = file.path.replaceAll('/storage/emulated/0/', '');
  //
  //         showCustomSnackBar('${'download_complete_file_saved_at'.tr} $relativePath', isError: false);
  //       } else {
  //         showCustomSnackBar('download_failed'.tr);
  //       }
  //     } else if (status.isDenied || status.isPermanentlyDenied) {
  //       showCustomSnackBar('permission_denied_cannot_download_the_file'.tr);
  //     }
  //   } catch (e) {
  //     showCustomSnackBar('download_failed'.tr);
  //   }
  // }

}

/// MM/dd/yyyy → yyyy-MM-dd
String _convertDateFormat(String inputDate) {
  try {
    if(inputDate.contains('-')) return inputDate;
    final parts = inputDate.split('/');

    if (parts.length != 3) return '';

    final month = parts[0].padLeft(2, '0');
    final day = parts[1].padLeft(2, '0');
    final year = parts[2];

    return '$year-$month-$day';
  } catch (e) {
    return '';
  }
}