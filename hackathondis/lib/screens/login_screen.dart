import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // To access AppColors

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoadingLogin = false;
  bool _isLoadingGoogle = false;

  // Static credentials for demo
  final String _validEmail = '123';
  final String _validPassword = '123';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Modified to use static authentication
  void _handleLogin() async {
    setState(() => _isLoadingLogin = true);

    // Simple validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      setState(() => _isLoadingLogin = false);
      return;
    }

    // Static authentication check
    if (_emailController.text == _validEmail &&
        _passwordController.text == _validPassword) {
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      Navigator.pushReplacementNamed(context, '/navbar');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }

    if (mounted) {
      setState(() => _isLoadingLogin = false);
    }
  }

  // Modified to use static authentication
  void _handleGoogleSignIn() async {
    setState(() => _isLoadingGoogle = true);
    await Future.delayed(const Duration(seconds: 1));

    // Simply navigate to home for demo purposes
    Navigator.pushReplacementNamed(context, '/navbar');

    if (mounted) {
      setState(() => _isLoadingGoogle = false);
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
              AppColors.primaryBlue.withOpacity(0.3),
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
                // Animated Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF47B04E).withOpacity(0.08),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFF006999).withOpacity(0.04),
                            blurRadius: 50,
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/logo.png', height: 220),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Easy Parking',
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Email & Password Fields
                _buildTextField('Email', false, _emailController),
                const SizedBox(height: 15),
                _buildTextField('Password', true, _passwordController),
                const SizedBox(height: 30),

                // Login Button
                _buildLoginButton(),
                const SizedBox(height: 20),

                // Google Sign In Button
                _buildGoogleSignInButton(),
                const SizedBox(height: 10),

                // Other Links
                _buildForgotPasswordButton(),
                _buildSignupPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    bool obscureText,
    TextEditingController controller,
  ) {
    return TextField(
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
        ),
      ),
      style: GoogleFonts.poppins(color: Colors.white),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoadingLogin ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        elevation: 6,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: _isLoadingLogin
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primaryBlue,
              ),
            )
          : Text(
              'Login',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppColors.primaryBlue,
              ),
            ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return ElevatedButton(
      onPressed: _isLoadingGoogle ? null : _handleGoogleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        elevation: 6,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: _isLoadingGoogle
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primaryBlue,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sign in with Google',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
      child: Text(
        'Forgot Password?',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
      ),
    );
  }

  Widget _buildSignupPrompt() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/signup'),
      child: Text(
        'Create New Account',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
