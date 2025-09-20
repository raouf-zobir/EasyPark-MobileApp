// lib/services/payment_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentApiService {
  // ‼️ IMPORTANT: For physical device testing, replace 'localhost' with your computer's IP address.
  // Example: final String _baseUrl = "http://192.168.1.5:5000/api/payments";
  static const String _baseUrl = "http://192.168.1.8:5000/api/payments";

  // 🔹 Initiates a payment and returns the response data
  Future<Map<String, dynamic>> initiatePayment(double amount) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/initiate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initiate payment: ${response.body}');
    }
  }

  // 🔹 Gets payment details for a given order number
  Future<Map<String, dynamic>> getPaymentDetails(String orderNumber) async {
    final response = await http.get(Uri.parse('$_baseUrl/show/$orderNumber'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get payment details: ${response.body}');
    }
  }

  // 🔹 Gets the receipt URL
  Future<Map<String, dynamic>> getReceipt(String orderNumber) async {
    final response = await http.get(Uri.parse('$_baseUrl/receipt/$orderNumber'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get receipt: ${response.body}');
    }
  }

  // 🔹 Sends the receipt to an email address
  Future<Map<String, dynamic>> emailReceipt(String orderNumber, String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'order_number': orderNumber, 'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to email receipt: ${response.body}');
    }
  }
}