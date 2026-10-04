import 'package:get/get_connect/http/src/response/response.dart';

class ResponseModel {
  final bool _isSuccess;
  final String? _message;
  final Response? biometricResponse;

  ResponseModel(this._isSuccess, this._message, {this.biometricResponse});

  bool get isSuccess => _isSuccess;
  String? get message => _message;
  Response? get response => biometricResponse;
}