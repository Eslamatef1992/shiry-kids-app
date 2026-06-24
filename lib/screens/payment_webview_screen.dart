import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_colors.dart';
import '../l10n/app_strings.dart';

/// Opens a Tap Payments hosted page (e.g. the KNET bank-authentication
/// redirect) inside a WebView. Once the page navigates back to the backend's
/// `/payments/tap/return` callback, this screen pops itself — the caller
/// should then poll `ApiService.getPaymentStatus` for the final result.
class PaymentWebviewScreen extends StatefulWidget {
  final String url;
  // URL prefix that marks the Tap return callback, e.g.
  // 'https://back.sherykids.com/api/v1/payments/tap/return'
  final String returnUrlPrefix;

  const PaymentWebviewScreen({super.key, required this.url, required this.returnUrlPrefix});

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          if (!_done && url.startsWith(widget.returnUrlPrefix)) {
            _done = true;
            Navigator.of(context).pop(true);
            return;
          }
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Pay Now'.tr(context),style: const TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ]),
    );
  }
}
