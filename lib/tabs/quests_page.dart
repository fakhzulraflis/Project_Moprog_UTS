import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  // Data sementara. Nanti diganti dengan data asli dari backend.
  static const List<Map<String, dynamic>> dailyQuests = [
    {
      'title': 'Earn 50 XP',
      'icon': 'assets/icons/xp.png',
      'progress': 20,
      'target': 50,
    },
    {
      'title': 'Complete 3 lessons',
      'icon': 'assets/icons/guidebook.png',
      'progress': 1,
      'target': 3,
    },
    {
      'title': 'Practice 5 times',
      'icon': 'assets/icons/dumbell.png',
      'progress': 0,
      'target': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Quests',
              style: GoogleFonts.baloo2(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            buildMonthlyChallenge(),

            const SizedBox(height: 30),

            buildSectionHeader('Daily Quests', '14 HOURS'),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF20272B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < dailyQuests.length; i++) ...[
                    buildQuestItem(dailyQuests[i]),

                    // Garis pemisah di antara quest, kecuali setelah yang terakhir
                    if (i < dailyQuests.length - 1)
                      const Divider(
                        height: 1,
                        color: Color.fromARGB(30, 255, 255, 255),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            buildSectionHeader('Flock Quest', 'NEXT IN 2 DAYS'),

            const SizedBox(height: 12),

            buildFlockQuest(),
          ],
        ),
      ),
    );
  }

  // Banner tantangan bulanan di bagian paling atas.
  Widget buildMonthlyChallenge() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D8C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEPTEMBER CHALLENGE',
                        style: GoogleFonts.baloo2(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Golden Pond Adventure',
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '8 DAYS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/app/wavingduck.gif',
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Kotak putih berisi progress tantangan
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF20272B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete 30 quests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: buildProgressBar(8, 30)),
                    const SizedBox(width: 12),
                    buildGoldenEgg(34),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title, String timeLeft) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Color(0xFFE7C249),
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              timeLeft,
              style: const TextStyle(
                color: Color(0xFFE7C249),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildQuestItem(Map<String, dynamic> quest) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Image.asset(quest['icon'], height: 40, fit: BoxFit.contain),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                buildProgressBar(quest['progress'], quest['target']),
              ],
            ),
          ),

          const SizedBox(width: 12),

          buildGoldenEgg(28),
        ],
      ),
    );
  }

  Widget buildFlockQuest() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete 20 lessons with your flock',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Team up with a friend and earn a golden egg together.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: buildProgressBar(0, 20)),
              const SizedBox(width: 12),
              buildGoldenEgg(28),
            ],
          ),
        ],
      ),
    );
  }

  // Progress bar dengan tulisan angka di tengahnya.
  Widget buildProgressBar(int progress, int target) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress / target,
            minHeight: 18,
            backgroundColor: const Color(0xFF3A4449),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFE7C249)),
          ),
        ),
        Text(
          '$progress / $target',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Ikon telur emas sebagai hadiah quest. Digambar pakai Container supaya
  // tidak perlu file gambar baru. Bagian atas dibuat lebih lancip dari bagian
  // bawah supaya bentuknya mirip telur.
  Widget buildGoldenEgg(double size) {
    return Container(
      width: size * 0.78,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE680),
            Color(0xFFE7C249),
            Color(0xFFB8860B),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(size * 0.39, size * 0.6),
          bottom: Radius.elliptical(size * 0.39, size * 0.4),
        ),
      ),
    );
  }
}
