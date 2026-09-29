import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/language_asset_service.dart';

class LoginPage extends StatelessWidget {
  final String selectedLanguage;

  const LoginPage({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: 190,
                  height: 160,
                  child: Image.asset(
                    LanguageAssetService.avatarFor(selectedLanguage),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sign in to continue learning.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20272B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Login form coming soon.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pixelifySans(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
