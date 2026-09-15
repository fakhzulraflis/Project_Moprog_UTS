import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'language_selection_page.dart';

class UnderstandPage extends StatefulWidget {
  const UnderstandPage({super.key});

  @override
  State<UnderstandPage> createState() => _UnderstandPageState();
}

class _UnderstandPageState extends State<UnderstandPage> {
  static const _messages = [
    "Hi there! I'm Qua.",
    'Nice to meet you!',
    "I'm your linguistics buddy.",
    "We'll learn one quack at a time.",
    'Ready to start your journey?',
  ];

  late final Timer _typingTimer;
  int _messageIndex = 0;
  int _characterIndex = 0;
  int _pauseElapsed = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;

      final currentMessage = _messages[_messageIndex];

      setState(() {
        if (_isPaused) {
          _pauseElapsed += 50;
          if (_pauseElapsed >= 1500) {
            _messageIndex = (_messageIndex + 1) % _messages.length;
            _characterIndex = 0;
            _pauseElapsed = 0;
            _isPaused = false;
          }
        } else if (_characterIndex >= currentMessage.length) {
          _isPaused = true;
        } else {
          _characterIndex++;
        }
      });
    });
  }

  @override
  void dispose() {
    _typingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMessage = _messages[_messageIndex];
    final safeCharacterIndex = _characterIndex.clamp(0, currentMessage.length);
    final typedMessage = currentMessage.substring(0, safeCharacterIndex);

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
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF20272B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color.fromARGB(110, 255, 255, 255),
                  ),
                ),
                child: Text(
                  typedMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pixelifySans(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                // Duck Closer
                padding: const EdgeInsets.only(top: 1, bottom: 0),
                child: Container(
                  padding: const EdgeInsets.only(top: 0, bottom: 4),
                  child: Image.asset(
                    'assets/app/qua.gif',
                    height: 210,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSelectionPage(),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
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
