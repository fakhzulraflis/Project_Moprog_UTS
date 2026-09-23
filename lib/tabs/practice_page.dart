import 'package:flutter/material.dart';

import '../pages/words_practice_page.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Practice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Strengthen your language skills!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              // Words Practice
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordsPracticePage(),
                    ),
                  );
                },
                child: _buildPracticeCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Words Practice',
                  description: 'Review your vocabulary',
                ),
              ),

              // Mistakes Review
              _buildPracticeCard(
                icon: Icons.refresh_rounded,
                title: 'Mistakes Review',
                description: 'Practice your incorrect answers',
              ),

              // Translation Practice
              _buildPracticeCard(
                icon: Icons.translate_rounded,
                title: 'Translation Practice',
                description: 'Translate words and sentences',
              ),

              // Sentence Builder
              _buildPracticeCard(
                icon: Icons.extension_rounded,
                title: 'Sentence Builder',
                description: 'Arrange words into sentences',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE7C249),
            size: 32,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white70,
            size: 18,
          ),
        ],
      ),
    );
  }
}