import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/shop_page.dart';
import '../services/player_progress.dart';
import '../widgets/reward_chest.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  final progress = PlayerProgress.instance;

  // Memperbarui hitung mundur dan me-reset quest tepat tengah malam.
  Timer? clock;

  static const List<String> monthNames = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  @override
  void initState() {
    super.initState();
    progress.load();
    clock = Timer.periodic(const Duration(seconds: 30), (_) {
      progress.refresh();
      setState(() {});
    });
  }

  @override
  void dispose() {
    clock?.cancel();
    super.dispose();
  }

  // Sisa waktu sampai quest harian di-reset (tengah malam).
  String get dailyTimeLeft {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final left = midnight.difference(now);

    if (left.inHours >= 1) {
      return '${left.inHours} ${left.inHours == 1 ? 'HOUR' : 'HOURS'}';
    }
    final minutes = left.inMinutes < 1 ? 1 : left.inMinutes;
    return '$minutes ${minutes == 1 ? 'MINUTE' : 'MINUTES'}';
  }

  // Sisa hari sampai challenge bulanan berakhir, termasuk hari ini.
  int get monthlyDaysLeft {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return lastDay - now.day + 1;
  }

  Future<void> openQuestChest(DailyQuest quest) async {
    final loot = await showChestOpening(context, quest.tier);
    if (loot == null) return;
    await progress.claimQuest(quest, loot);
  }

  Future<void> openMonthlyChest() async {
    final loot = await showChestOpening(context, ChestTier.gold);
    if (loot == null) return;
    await progress.claimMonthly(loot);
  }

  void openShop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            if (!progress.isLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE7C249)),
              );
            }

            final quests = PlayerProgress.dailyQuests;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Quests',
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buildGemButton(),
                  ],
                ),

                if (progress.isXpBoostActive) ...[
                  const SizedBox(height: 10),
                  buildBoostBanner(),
                ],

                const SizedBox(height: 15),

                buildMonthlyChallenge(),

                const SizedBox(height: 30),

                buildSectionHeader('Daily Quests', dailyTimeLeft),

                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF20272B),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < quests.length; i++) ...[
                        buildQuestItem(quests[i]),

                        // Garis pemisah di antara quest, kecuali setelah yang terakhir
                        if (i < quests.length - 1)
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
            );
          },
        ),
      ),
    );
  }

  // Saldo gem di pojok kanan atas. Ditekan untuk membuka toko.
  Widget buildGemButton() {
    return GestureDetector(
      onTap: openShop,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromARGB(40, 255, 255, 255)),
        ),
        child: Row(
          children: [
            Image.asset('assets/icons/gems.png', height: 20),
            const SizedBox(width: 6),
            Text(
              '${progress.gems}',
              style: const TextStyle(
                color: Color(0xFF1CB0F6),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.storefront, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget buildBoostBanner() {
    final minutes = progress.xpBoostLeft.inMinutes + 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3B2F5C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/xp.png', height: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'XP Boost active: 2x XP, $minutes min left',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                        '${monthNames[DateTime.now().month - 1]} CHALLENGE',
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
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            monthlyDaysLeft == 1
                                ? '1 DAY'
                                : '$monthlyDaysLeft DAYS',
                            style: const TextStyle(
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
                  'Complete ${PlayerProgress.monthlyTarget} quests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: buildProgressBar(
                        progress.questsThisMonth.clamp(
                          0,
                          PlayerProgress.monthlyTarget,
                        ),
                        PlayerProgress.monthlyTarget,
                      ),
                    ),
                    const SizedBox(width: 12),
                    RewardChest(
                      tier: ChestTier.gold,
                      size: 46,
                      state: progress.monthlyChestState,
                      onTap: openMonthlyChest,
                    ),
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

  Widget buildQuestItem(DailyQuest quest) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Image.asset(quest.icon, height: 40, fit: BoxFit.contain),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                buildProgressBar(progress.progressOf(quest), quest.target),
              ],
            ),
          ),

          const SizedBox(width: 12),

          RewardChest(
            tier: quest.tier,
            size: 40,
            state: progress.chestStateOf(quest),
            onTap: () => openQuestChest(quest),
          ),
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
            'Team up with a friend and open a silver chest together.',
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
              // Flock quest belum tersambung ke data teman, jadi petinya
              // selalu terkunci.
              const RewardChest(
                tier: ChestTier.silver,
                size: 40,
                state: ChestState.locked,
              ),
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
}
