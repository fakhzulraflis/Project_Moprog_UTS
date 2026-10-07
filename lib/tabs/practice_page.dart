import 'package:flutter/material.dart';

import '../pages/memory_game_page.dart';
import '../pages/word_hunt_page.dart';
import '../pages/word_chase_page.dart';
import '../pages/mistake_review_page.dart';

class PracticePage extends StatelessWidget {
  final String selectedLanguage;

  const PracticePage({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latihan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Latih kembali apa yang sudah kamu pelajari!',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Permainan Mengingat
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemoryGamePage(
                                selectedLanguage: selectedLanguage,
                              ),
                            ),
                          );
                        },
                        child: buildPracticeCard(
                          icon: const ContainerMemoryIcon(),
                          title: 'Permainan Mengingat',
                          description: 'Temukan dan cocokkan pasangan kata yang tersembunyi',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Perburuan Kata
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordHuntPage(
                                selectedLanguage: selectedLanguage,
                              ),
                            ),
                          );
                        },
                        child: buildPracticeCard(
                          icon: const ContainerWordHuntIcon(),
                          title: 'Perburuan Kata',
                          description: 'Temukan kosakata yang tersembunyi di dalam susunan huruf',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Kejar Kata
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordChasePage(
                                selectedLanguage: selectedLanguage,
                              ),
                            ),
                          );
                        },
                        child: buildPracticeCard(
                          icon: const ContainerWordChaseIcon(),
                          title: 'Kejar Kata',
                          description: 'Jawab kosakata sebanyak mungkin sebelum waktu habis',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Review Kesalahan
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MistakeReviewPage(
                                selectedLanguage: selectedLanguage,
                              ),
                            ),
                          );
                        },
                        child: buildPracticeCard(
                          icon: const ContainerMistakeIcon(),
                          title: 'Review Kesalahan',
                          description: 'Latih kembali kosakata yang pernah kamu jawab salah',
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPracticeCard({
    required Widget icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromARGB(70, 255, 255, 255)),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white54,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class ContainerMemoryIcon extends StatelessWidget {
  const ContainerMemoryIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return buildIconContainer(Icons.psychology_rounded);
  }
}

class ContainerWordHuntIcon extends StatelessWidget {
  const ContainerWordHuntIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return buildIconContainer(Icons.search_rounded);
  }
}

class ContainerWordChaseIcon extends StatelessWidget {
  const ContainerWordChaseIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return buildIconContainer(Icons.bolt_rounded);
  }
}

class ContainerMistakeIcon extends StatelessWidget {
  const ContainerMistakeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return buildIconContainer(Icons.replay_rounded);
  }
}

Widget buildIconContainer(IconData icon) {
  return Container(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: const Color(0xFFE7C249),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Icon(icon, color: const Color(0xFF272F33), size: 34),
  );
}
