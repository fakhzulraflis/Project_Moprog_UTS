import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../tabs/home_page.dart';

import 'forgot_password_page.dart';
import 'understand_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.baloo2(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF20272B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7C249)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.baloo2(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHelperText(String text) {
    return Text(
      text,
      style: GoogleFonts.pixelifySans(color: Colors.white54, fontSize: 12),
    );
  }

  Widget _buildTextField({
    required String label,
    required String helperText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(label),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.baloo2(color: Colors.white),
            decoration: _inputDecoration(
              'Enter $label',
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
          const SizedBox(height: 4),
          _buildHelperText(helperText),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 231, 194, 73),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 190, 155, 45),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.login(
        usernameOrEmail: _usernameOrEmailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final user = response['user'] as Map<String, dynamic>? ?? {};
      final selectedLanguage =
          (user['learning_language'] as String?) ?? 'English';

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(selectedLanguage: selectedLanguage),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color.fromARGB(172, 255, 255, 255),
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Image.asset('assets/app/logo.png', height: 30),
                ],
              ),

              const SizedBox(height: 20),

              // Qua Mascot
              Center(
                child: SizedBox(
                  height: 180,
                  child: Image.asset('assets/app/qua.gif', fit: BoxFit.contain),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Welcome Back!',
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Ready for another quack?',
                  style: GoogleFonts.baloo2(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Form
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF20272B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Username or Email',
                        helperText: 'Example: shyang or name@email.com',
                        controller: _usernameOrEmailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username or email is required.';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Password',
                        helperText: 'Enter your Quacko account password.',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.white70,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required.';
                          }
                          return null;
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          ),
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.baloo2(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login Button
                      _buildPrimaryButton(
                        label: _isSubmitting ? 'LOGGING IN...' : 'LOGIN',
                        onPressed: _isSubmitting ? null : _handleLogin,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Create Account Shortcut
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.baloo2(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnderstandPage(),
                      ),
                    ),
                    child: Text(
                      'CREATE ONE',
                      style: GoogleFonts.baloo2(
                        color: Color.fromARGB(255, 231, 194, 73),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
