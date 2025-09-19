import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hackathondis/screens/baridi_payment_screen.dart';
// NOTE: You will need to add the 'pay' package for Google Pay
// import 'package:pay/pay.dart';

// ADDED: Import the Baridi payment screen to navigate to it

class TopUpScreen extends StatefulWidget {
  @override
  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  String selectedPaymentMethod = ''; // Empty string initially

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Payment Method",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Payment Method",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOption(
                      imageAsset: 'assets/images/baridi.png',
                      title: "Baridi Pay",
                      method: 'baridi',
                      selected: selectedPaymentMethod == 'baridi',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentOption(
                      icon: FontAwesomeIcons.googlePay,
                      title: "Google Pay",
                      method: 'google_pay',
                      selected: selectedPaymentMethod == 'google_pay',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentOption(
                      icon: FontAwesomeIcons.paypal,
                      title: "PayPal",
                      method: 'paypal',
                      selected: selectedPaymentMethod == 'paypal',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // --- REMOVED ---
              // The card form that was previously here has been removed.
              // The BaridiPaymentScreen will handle the form input.

            ],
          ),
        ),
      ),
      bottomNavigationBar: selectedPaymentMethod.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // --- UPDATED LOGIC ---
                    if (selectedPaymentMethod == 'baridi') {
                      // Navigate to the dedicated Baridi Payment Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BaridiPaymentScreen(
                            amount: 1000.00, // Example top-up amount
                            orderNumber: 'TOPUP-${DateTime.now().millisecondsSinceEpoch}',
                            fundraiserId: 'user_wallet_topup', // Dummy ID for wallet
                          ),
                        ),
                      );
                    } else if (selectedPaymentMethod == 'google_pay') {
                       // Placeholder for Google Pay
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Google Pay logic would go here.'))
                       );
                    } else if (selectedPaymentMethod == 'paypal') {
                       // Placeholder for PayPal
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('PayPal logic would go here.'))
                       );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF57AB7D), // Match profile theme color
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPaymentOption({
    IconData? icon,
    String? imageAsset,
    required String title,
    required String method,
    required bool selected,
  }) {
    final Color selectedColor = Color(0xFF57AB7D); // Match profile theme color

    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? selectedColor : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: selectedColor.withOpacity(0.15),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 32,
                color: selected ? selectedColor : Colors.grey[700],
              )
            else if (imageAsset != null)
              // Handle potential image asset loading error gracefully
              Image.asset(
                imageAsset,
                height: 32,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.credit_card,
                  size: 32,
                  color: Colors.grey[700],
                ),
              ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? selectedColor : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}