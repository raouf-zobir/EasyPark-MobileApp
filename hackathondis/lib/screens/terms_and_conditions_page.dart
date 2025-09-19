import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // To access AppColors

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '1. Introduction\n'
          'These terms and conditions outline the rules and regulations for the use of this app.\n\n'
          '2. Acceptance of Terms\n'
          'By accessing this app, we assume you accept these terms and conditions.\n\n'
          '3. Privacy Policy\n'
          'Your privacy is important to us, and we are committed to protecting your personal data.\n\n'
          '4. Changes to Terms\n'
          'We may update the terms and conditions periodically. Please review them regularly.\n\n'
          '5. Limitation of Liability\n'
          'In no event shall we be liable for any damages or losses.\n\n'
          '6. Governing Law\n'
          'These terms shall be governed by the laws of [Your Country].\n\n'
          'Please read all terms carefully before using the app.',
        ),
      ),
    );
  }
}