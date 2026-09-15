import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? selectedLanguage;
  String _message = 'What would you like to learn with Qua?';
  String _typedMessage = '';
  Timer? _typingTimer;
  int _characterIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  void _startTypingAnimation() {
    _typingTimer?.cancel();
    _characterIndex = 0;
    _typedMessage = '';

    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        if (_characterIndex < _message.length) {
          _characterIndex++;
          _typedMessage = _message.substring(0, _characterIndex);
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _updateMessage(String language) {
    setState(() {
      selectedLanguage = language;

      if (language == 'English') {
        _message = "English? Let's quack in English!";
      } else if (language == 'Japanese') {
        _message = "Japanese? Sugoi! Let's start!";
      } else {
        _message = 'Korean? Annyeong! Great pick!';
      }
    });

    _startTypingAnimation();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  Widget _buildLanguageCard({
    required String language,
    required String flagAsset,
  }) {
    final isSelected = selectedLanguage == language;

    return GestureDetector(
      onTap: () => _updateMessage(language),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 231, 194, 73)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Image.asset(flagAsset, height: 36, width: 36, fit: BoxFit.contain),
            const SizedBox(width: 16),
            Text(
              language,
              style: GoogleFonts.pixelifySans(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color.fromARGB(172, 255, 255, 255),
                          size: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/app/logo.png',
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              // BAR PROGRESS
              // const SizedBox(height: 18),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(20),
              //   child: const LinearProgressIndicator(
              //     value: 0.35,
              //     minHeight: 10,
              //     backgroundColor: Color(0xFF20272B),
              //     valueColor: AlwaysStoppedAnimation(
              //       Color.fromARGB(255, 231, 194, 73),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 100,
                    child: Transform.scale(
                      scale: 2.0,
                      child: Image.asset(
                        'assets/app/wavingduck.gif',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20272B),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color.fromARGB(110, 255, 255, 255),
                        ),
                      ),
                      child: Text(
                        _typedMessage,
                        style: GoogleFonts.pixelifySans(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildLanguageCard(
                      language: 'English',
                      flagAsset: 'assets/flags/inggris.png',
                    ),
                    _buildLanguageCard(
                      language: 'Japanese',
                      flagAsset: 'assets/flags/japan.png',
                    ),
                    _buildLanguageCard(
                      language: 'Korean',
                      flagAsset: 'assets/flags/korea.png',
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (selectedLanguage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please choose a language first.'),
                      ),
                    );
                    return;
                  }

                  print(selectedLanguage);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                    child: Center(
                      child: Text(
                        'CONTINUE',
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
