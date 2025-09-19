import 'package:flutter/material.dart';
import 'package:hackathondis/auth/OLD/terms_and_conditions_page.dart';
import 'package:hackathondis/screens/forgot_password_screen.dart';
import 'package:hackathondis/screens/login_screen.dart';
import 'package:hackathondis/screens/signup_screen.dart';
import 'package:hackathondis/screens/navbar_screen.dart'; // Add this import

// Define your new color palette
class AppColors {
  static const Color primaryBlue = Color(0xFF006999);
  static const Color primaryGreen = Color(0xFF47B04E);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DCF App',
      // The theme is mostly handled by the gradient backgrounds on each screen
      theme: ThemeData(useMaterial3: true, primaryColor: AppColors.primaryBlue),
      // Start the app at the Login Screen
      home: const LoginScreen(),
      // Define the routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/terms': (context) => const TermsAndConditionsPage(),
        '/navbar': (context) => const NavBarScreen(), // Add this route
      },
    );
  }
}
