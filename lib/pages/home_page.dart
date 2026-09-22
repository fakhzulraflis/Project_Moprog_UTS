import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: selectedTab == 0 ? buildBeranda() : buildProfil(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF20272B),
        selectedItemColor: const Color(0xFFE7C249),
        unselectedItemColor: Colors.white54,
        currentIndex: selectedTab,
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget buildBeranda() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Image.asset(
          'assets/app/logo.png',
          height: 30,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 20),

        // Maskot Qua di kiri, kotak sapaan di kanan
        Row(
          children: [
            Image.asset(
              'assets/app/wavingduck.gif',
              height: 90,
              fit: BoxFit.contain,
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
                child: const Text(
                  'Halo! Semua sudah siap. Ayo mulai belajar.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        const Text(
          'Statistik kamu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            buildStatCard('assets/icons/streak.png', '0', 'Streak'),
            const SizedBox(width: 12),
            buildStatCard('assets/icons/xp.png', '0', 'Total XP'),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            buildStatCard('assets/icons/gems.png', '0', 'Gems'),
            const SizedBox(width: 12),
            buildStatCard('assets/icons/hearts.png', '5', 'Nyawa'),
          ],
        ),

        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF20272B),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/guidebook.png',
                height: 36,
                fit: BoxFit.contain,
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Text(
                  'Materi pelajaran sedang disiapkan.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfil() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF20272B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE7C249),
                    width: 2,
                  ),
                ),
                child: Image.asset(
                  'assets/landing/char.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Quacker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Pembelajar baru',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        buildInfoRow('assets/icons/streak.png', 'Streak terpanjang', '0 hari'),
        buildInfoRow('assets/icons/xp.png', 'Total XP', '0'),
        buildInfoRow('assets/icons/finishesbadge.png', 'Lencana', '0'),
        buildInfoRow('assets/icons/silver.png', 'Liga', 'Belum ada'),
      ],
    );
  }

  // Kartu statistik. Dibungkus Expanded supaya dua kartu dalam satu baris
  // lebarnya selalu sama rata.
  Widget buildStatCard(String icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Image.asset(icon, height: 28, fit: BoxFit.contain),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Image.asset(icon, height: 26, fit: BoxFit.contain),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE7C249),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
