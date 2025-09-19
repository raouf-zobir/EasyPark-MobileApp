import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // To access AppColors

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool _isChecked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordCheckController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    // TODO: Add your real signup logic here.
    print('Signing up with Name: ${_nameController.text}, Email: ${_emailController.text}');
    if (mounted) {
      setState(() => _isLoading = false);
      // On success, maybe show a verification message and navigate to login
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppColors.primaryBlue.withOpacity(0.2),
              AppColors.primaryGreen.withOpacity(0.4),
              AppColors.primaryBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 180),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 30),
                _buildTextField('Full Name', false, _nameController),
                const SizedBox(height: 15),
                _buildTextField('Email', false, _emailController),
                const SizedBox(height: 15),
                _buildTextField('Password', true, _passwordController),
                const SizedBox(height: 15),
                _buildTextField('Confirm Password', true, _passwordCheckController),
                const SizedBox(height: 20),
                _buildTermsCheckbox(),
                const SizedBox(height: 20),
                _buildSignUpButton(),
                const SizedBox(height: 10),
                _buildLoginPrompt(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, bool obscureText, TextEditingController controller) {
    return SlideTransition(
      position: _slideAnimation,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.15),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        ),
        style: GoogleFonts.poppins(color: Colors.white),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return SlideTransition(
      position: _slideAnimation,
      child: Row(
        children: [
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _isChecked,
              onChanged: (value) => setState(() => _isChecked = value ?? false),
              activeColor: Colors.white,
              checkColor: AppColors.primaryBlue,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.pushNamed(context, '/terms'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: ElevatedButton(
        onPressed: (_isLoading || !_isChecked) ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          elevation: 6,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : Text(
                'Sign Up',
                style: GoogleFonts.poppins(fontSize: 18, color: AppColors.primaryBlue),
              ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: TextButton(
        onPressed: () => Navigator.pop(context), // Go back to login screen
        child: const Text(
          'Already have an account? Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}