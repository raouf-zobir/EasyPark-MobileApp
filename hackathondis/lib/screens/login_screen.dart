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
  bool _obscurePassword = true;

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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/parking.png'), // Using existing parking image
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // EP Logo and Branding
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          // EP Logo
                          Container(
                            width: 80,
                            height: 80,
                            child: Stack(
                              children: [
                                // E letter
                                Positioned(
                                  left: 10,
                                  top: 15,
                                  child: Container(
                                    width: 25,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00BCD4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                // E horizontal lines
                                Positioned(
                                  left: 10,
                                  top: 15,
                                  child: Container(width: 20, height: 8, color: const Color(0xFF00BCD4)),
                                ),
                                Positioned(
                                  left: 10,
                                  top: 36,
                                  child: Container(width: 15, height: 6, color: const Color(0xFF00BCD4)),
                                ),
                                Positioned(
                                  left: 10,
                                  top: 57,
                                  child: Container(width: 20, height: 8, color: const Color(0xFF00BCD4)),
                                ),
                                // P letter
                                Positioned(
                                  right: 10,
                                  top: 15,
                                  child: Container(
                                    width: 25,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                // P horizontal line
                                Positioned(
                                  right: 10,
                                  top: 15,
                                  child: Container(width: 20, height: 8, color: const Color(0xFF4CAF50)),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 36,
                                  child: Container(width: 15, height: 6, color: const Color(0xFF4CAF50)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'E-Parking',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Parking made easy',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Login Form
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      Text(
                        'Email Address',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildGlassTextField(
                        'Enter your email',
                        false,
                        _emailController,
                        Icons.email_outlined,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll send a verification link to your email.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Password Field
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildGlassTextField(
                        'Enter your password',
                        _obscurePassword,
                        _passwordController,
                        Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Make sure your password is at least 8 characters long.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Forgot Password Button
                      _buildGlassButton('Forgot Password?', false),
                      
                      const SizedBox(height: 16),
                      
                      // Create Account Button
                      _buildGlassButton('Create Account', false),
                      
                      const SizedBox(height: 24),
                      
                      // Sign In Button
                      _buildSignInButton(),
                      
                      const SizedBox(height: 32),
                      
                      // OR Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Social Sign In Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(Icons.g_mobiledata, () => _handleGoogleSignIn()),
                          const SizedBox(width: 24),
                          _buildSocialIcon(Icons.apple, () {}),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField(
    String hintText,
    bool obscureText,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildGlassButton(String text, bool isPrimary) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: () {
          if (text == 'Forgot Password?') {
            Navigator.pushNamed(context, '/forgot-password');
          } else if (text == 'Create Account') {
            Navigator.pushNamed(context, '/signup');
          }
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: _isLoadingLogin ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoadingLogin
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}
