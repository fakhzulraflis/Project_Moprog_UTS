import 'package:flutter/material.dart';

import '../pages/lesson_page.dart';

class LearnPage extends StatefulWidget {
  final String selectedLanguage;

  const LearnPage({super.key, required this.selectedLanguage});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  bool circle1Completed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // =========================
              // TOP BAR
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LANGUAGE
                    Text(
                      _getLanguageFlag(),
                      style: const TextStyle(fontSize: 28),
                    ),

                    // STATS
                    Row(
                      children: const [
                        Icon(Icons.local_fire_department, color: Colors.orange),

                        SizedBox(width: 5),

                        Text(
                          '0',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 18),

                        Icon(Icons.diamond, color: Colors.lightBlue),

                        SizedBox(width: 5),

                        Text(
                          '0',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 18),

                        Icon(Icons.favorite, color: Colors.redAccent),

                        SizedBox(width: 5),

                        Text(
                          '5',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =========================
              // UNIT HEADER
              // =========================
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFF3B8C5A),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECTION 1',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Getting Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'UNIT 1 • Order Food & Drinks',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // CIRCLE 1
              // FOOD VOCABULARY
              // =========================
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonPage(
                        selectedLanguage: widget.selectedLanguage,
                        circleTitle: 'Food Vocabulary',
                      ),
                    ),
                  );

                  if (!mounted) return;

                  setState(() {
                    circle1Completed = true;
                  });
                },

                child: _lessonCircle(
                  icon: Icons.restaurant,
                  color: const Color(0xFFE7C249),
                  completed: circle1Completed,
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // CIRCLE 2
              // DRINK VOCABULARY
              // =========================
              GestureDetector(
                onTap: circle1Completed
                    ? () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonPage(
                              selectedLanguage: widget.selectedLanguage,
                              circleTitle: 'Drinks Vocabulary',
                            ),
                          ),
                        );
                      }
                    : null,

                child: _lessonCircle(
                  icon: Icons.local_cafe,
                  color: circle1Completed
                      ? const Color(0xFFE7C249)
                      : Colors.grey,
                  locked: !circle1Completed,
                ),
              ),

              const SizedBox(height: 35),

              // =========================
              // CIRCLE 3
              // ORDERING FOOD
              // =========================
              _lessonCircle(
                icon: Icons.restaurant_menu,
                color: Colors.grey,
                locked: true,
              ),

              const SizedBox(height: 35),

              // =========================
              // CIRCLE 4
              // ORDERING DRINKS
              // =========================
              _lessonCircle(
                icon: Icons.local_drink,
                color: Colors.grey,
                locked: true,
              ),

              const SizedBox(height: 35),

              // =========================
              // CIRCLE 5
              // REVIEW
              // =========================
              _lessonCircle(icon: Icons.star, color: Colors.grey, locked: true),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // LANGUAGE FLAG
  // =========================
  String _getLanguageFlag() {
    switch (widget.selectedLanguage) {
      case 'Japanese':
        return '🇯🇵';

      case 'Korean':
        return '🇰🇷';

      case 'English':
      default:
        return '🇬🇧';
    }
  }

  // =========================
  // LESSON CIRCLE
  // =========================
  Widget _lessonCircle({
    required IconData icon,
    required Color color,
    bool locked = false,
    bool completed = false,
  }) {
    return Container(
      width: 80,
      height: 80,

      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Icon(
        locked
            ? Icons.lock
            : completed
            ? Icons.check
            : icon,

        color: locked ? Colors.white54 : Colors.black,

        size: 32,
      ),
    );
  }
}
