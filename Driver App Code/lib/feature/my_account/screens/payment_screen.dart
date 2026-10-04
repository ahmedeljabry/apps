import 'package:stackfood_multivendor_driver/feature/my_account/widgets/fund_payment_dialog_widget.dart';
import 'package:stackfood_multivendor_driver/helper/route_helper.dart';
import 'package:stackfood_multivendor_driver/util/app_constants.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final String? redirectUrl;
  const PaymentScreen({super.key, this.redirectUrl});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late final String selectedUrl;
  bool _isLoading = true;
  String? _loadError;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.redirectUrl?.trim() ?? '';
    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(),
      onRefresh: () async => _webViewController?.reload(),
    );
  }

  bool get _hasValidUrl {
    final uri = Uri.tryParse(selectedUrl);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _exitApp().then((value) => value!);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBarWidget(
          title: 'payment'.tr,
          onBackPressed: () => _exitApp(),
        ),
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: !_hasValidUrl
                ? _PaymentLoadError(onRetry: () => Get.back())
                : Stack(
                    children: [
                      InAppWebView(
                        initialUrlRequest: URLRequest(url: WebUri(selectedUrl)),
                        initialSettings: InAppWebViewSettings(
                          useShouldOverrideUrlLoading: true,
                          javaScriptEnabled: true,
                          transparentBackground: false,
                        ),
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) =>
                            _webViewController = controller,
                        onLoadStart: (controller, url) {
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                              _loadError = null;
                            });
                          }
                          _redirect(url?.toString() ?? '');
                        },
                        onLoadStop: (controller, url) async {
                          await pullToRefreshController?.endRefreshing();
                          if (mounted) setState(() => _isLoading = false);
                          _redirect(url?.toString() ?? '');
                        },
                        onReceivedError: (controller, request, error) async {
                          await pullToRefreshController?.endRefreshing();
                          if (request.isForMainFrame == true && mounted) {
                            setState(() {
                              _isLoading = false;
                              _loadError = error.description;
                            });
                          }
                        },
                        shouldOverrideUrlLoading: (controller, action) async {
                          final uri = action.request.url;
                          if (uri != null &&
                              ![
                                'http',
                                'https',
                                'file',
                                'data',
                                'javascript',
                                'about',
                              ].contains(uri.scheme)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            return NavigationActionPolicy.CANCEL;
                          }
                          return NavigationActionPolicy.ALLOW;
                        },
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_loadError != null && !_isLoading)
                        Positioned.fill(
                          child: _PaymentLoadError(
                            onRetry: () {
                              setState(() {
                                _loadError = null;
                                _isLoading = true;
                              });
                              _webViewController?.reload();
                            },
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    return Get.dialog(const FundPaymentDialogWidget());
  }

  void _redirect(String url) {
    if (url.isEmpty) {
      return;
    }
    final isSuccess =
        url.contains('${AppConstants.baseUrl}/payment-success') ||
        url.contains('${AppConstants.baseUrl}/success?flag=success');
    final isFailed =
        url.contains('${AppConstants.baseUrl}/payment-fail') ||
        url.contains('${AppConstants.baseUrl}/success?flag=fail');
    final isCancel =
        url.contains('${AppConstants.baseUrl}/payment-cancel') ||
        url.contains('${AppConstants.baseUrl}/success?flag=cancel');
    if (isSuccess || isFailed || isCancel) {
      Get.offNamed(
        RouteHelper.getSuccessRoute(
          isSuccess
              ? 'success'
              : isFailed
              ? 'fail'
              : 'cancel',
        ),
      );
    }
  }
}

class _PaymentLoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const _PaymentLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'unable_to_load_payment_page'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            FilledButton(onPressed: onRetry, child: Text('try_again'.tr)),
          ],
        ),
      ),
    );
  }
}
