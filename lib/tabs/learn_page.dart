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

  static const Color backgroundColor = Color(0xFF272F33);
  static const Color yellowColor = Color(0xFFFCCF10);
  static const Color cardColor = Color(0xFF3B8C5A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

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
                    Text(
                      _getLanguageFlag(),
                      style: const TextStyle(fontSize: 28),
                    ),

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
                  color: cardColor,
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

              const SizedBox(height: 30),

              // =========================
              // LESSON PATH
              // =========================
              SizedBox(
                height: 620,
                child: Stack(
                  children: [
                    // =========================
                    // CURVED PATH
                    // =========================
                    Positioned.fill(
                      child: CustomPaint(
                        painter: LessonPathPainter(
                          completedFirst: circle1Completed,
                        ),
                      ),
                    ),

                    // =========================
                    // LESSON 1
                    // LEFT
                    // =========================
                    Positioned(
                      top: 20,
                      left: 55,
                      child: _buildLessonNode(
                        icon: Icons.restaurant,
                        color: yellowColor,
                        completed: circle1Completed,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LessonPage(lessonId: 1),
                            ),
                          );

                          if (!mounted) return;

                          if (result == true) {
                            setState(() {
                              circle1Completed = true;
                            });
                          }
                        },
                      ),
                    ),

                    // =========================
                    // LESSON 2
                    // RIGHT
                    // =========================
                    Positioned(
                      top: 145,
                      right: 55,
                      child: _buildLessonNode(
                        icon: Icons.local_cafe,
                        color: circle1Completed
                            ? yellowColor
                            : Colors.grey.shade700,
                        locked: !circle1Completed,
                        onTap: circle1Completed
                            ? () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LessonPage(lessonId: 2),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),

                    // =========================
                    // LESSON 3
                    // LEFT
                    // =========================
                    Positioned(
                      top: 270,
                      left: 45,
                      child: _buildLessonNode(
                        icon: Icons.restaurant_menu,
                        color: Colors.grey.shade700,
                        locked: true,
                      ),
                    ),

                    // =========================
                    // LESSON 4
                    // RIGHT
                    // =========================
                    Positioned(
                      top: 395,
                      right: 45,
                      child: _buildLessonNode(
                        icon: Icons.local_drink,
                        color: Colors.grey.shade700,
                        locked: true,
                      ),
                    ),

                    // =========================
                    // LESSON 5
                    // CENTER
                    // =========================
                    Positioned(
                      top: 520,
                      left: MediaQuery.of(context).size.width / 2 - 40,
                      child: _buildLessonNode(
                        icon: Icons.star,
                        color: Colors.grey.shade700,
                        locked: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // LESSON NODE
  // =========================
  Widget _buildLessonNode({
    required IconData icon,
    required Color color,
    bool locked = false,
    bool completed = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 0,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: Icon(
                locked
                    ? Icons.lock
                    : completed
                    ? Icons.check
                    : icon,
                color: locked ? Colors.white54 : Colors.black87,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            locked
                ? 'Locked'
                : completed
                ? 'Completed'
                : 'Start',
            style: TextStyle(
              color: locked ? Colors.white38 : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
}

// =====================================================
// CURVED LESSON PATH
// =====================================================

class LessonPathPainter extends CustomPainter {
  final bool completedFirst;

  LessonPathPainter({required this.completedFirst});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    final center = size.width / 2;

    // Lesson 1 → Lesson 2
    path.moveTo(95, 65);

    path.cubicTo(120, 80, size.width - 120, 90, size.width - 95, 185);

    // Lesson 2 → Lesson 3
    path.moveTo(size.width - 95, 185);

    path.cubicTo(size.width - 120, 230, 120, 245, 85, 310);

    // Lesson 3 → Lesson 4
    path.moveTo(85, 310);

    path.cubicTo(120, 355, size.width - 120, 365, size.width - 85, 435);

    // Lesson 4 → Lesson 5
    path.moveTo(size.width - 85, 435);

    path.cubicTo(size.width - 110, 480, center + 30, 500, center, 560);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.15);

    canvas.drawPath(path, paint);

    // =========================
    // COMPLETED PATH
    // =========================
    if (completedFirst) {
      final completedPath = Path();

      completedPath.moveTo(95, 65);

      completedPath.cubicTo(
        120,
        80,
        size.width - 120,
        90,
        size.width - 95,
        185,
      );

      final completedPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFCCF10);

      canvas.drawPath(completedPath, completedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LessonPathPainter oldDelegate) {
    return oldDelegate.completedFirst != completedFirst;
  }
}
