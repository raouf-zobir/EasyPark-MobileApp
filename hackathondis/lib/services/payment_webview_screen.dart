// lib/screens/payment_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:hackathondis/screens/order_details_screen.dart'; // We will create this next

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String orderId;

  const PaymentWebViewScreen({
    Key? key,
    required this.paymentUrl,
    required this.orderId,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // You can use this to show a progress bar
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error
          },
          onNavigationRequest: (NavigationRequest request) {
            // ‼️ IMPORTANT: These are placeholder URLs. You must configure your payment
            // gateway (SATIM) to redirect to these exact URLs upon success or failure.
            const String successUrl = 'https://easypark.dz/payment/success';
            const String failureUrl = 'https://easypark.dz/payment/failure';

            if (request.url.startsWith(successUrl)) {
              // Payment was successful, navigate to the order details screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(orderId: widget.orderId),
                ),
              );
              return NavigationDecision.prevent; // Prevent the webview from navigating
            }
            if (request.url.startsWith(failureUrl)) {
              // Payment failed, pop back and show a message
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment failed or was cancelled.'),
                  backgroundColor: Colors.red,
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate; // Allow navigation for other URLs
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}