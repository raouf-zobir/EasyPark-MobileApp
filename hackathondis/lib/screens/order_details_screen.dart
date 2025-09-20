// lib/screens/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:hackathondis/services/payment_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final PaymentApiService _apiService = PaymentApiService();
  Future<Map<String, dynamic>>? _paymentDetailsFuture;

  @override
  void initState() {
    super.initState();
    _paymentDetailsFuture = _apiService.getPaymentDetails(widget.orderId);
  }

  Future<void> _downloadReceipt() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await _apiService.getReceipt(widget.orderId);
      final receiptUrl = response['links']?['href'];

      if (receiptUrl != null) {
        final uri = Uri.parse(receiptUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text('Could not launch URL: $receiptUrl'), backgroundColor: Colors.orange),
          );
        }
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Receipt URL not found in API response.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error getting receipt: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _emailReceipt() async {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send Receipt to Email'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Enter your email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                
                try {
                  await _apiService.emailReceipt(widget.orderId, emailController.text);
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Receipt sent successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                   navigator.pop();
                   messenger.showSnackBar(
                    SnackBar(content: Text('Error sending receipt: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Details'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context)
              .popUntil((route) => route.isFirst), // Go back to map screen
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _paymentDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final details = snapshot.data!['data']['attributes'];
          final status = details['status'] ?? 'N/A';
          final amount = details['amount'] ?? '0';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Payment Successful!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green.shade700)),
                    const SizedBox(height: 24),
                    _buildDetailRow('Order Number:', widget.orderId),
                    _buildDetailRow('Status:', status.toString().replaceAll('_', ' ').toUpperCase()),
                    _buildDetailRow('Amount:', '$amount DA'),
                    const Divider(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Download Receipt'),
                      onPressed: _downloadReceipt,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.email),
                      label: const Text('Send Receipt to Email'),
                      onPressed: _emailReceipt,
                       style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}