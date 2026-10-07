import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/daily_spin_page.dart';
import '../pages/pet_page.dart';
import '../pages/shop_page.dart';
import '../pages/streak_calendar_page.dart';
import '../services/duck_pet.dart';
import '../services/inventory_service.dart';
import '../services/player_progress.dart';
import '../widgets/duck_painter.dart';
import '../widgets/inventory_button.dart';
import '../widgets/reward_chest.dart';
import '../widgets/spin_wheel.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  final progress = PlayerProgress.instance;
  final pet = DuckPet.instance;

  // Memperbarui hitung mundur dan me-reset quest tepat tengah malam.
  Timer? clock;

  static const List<String> monthNames = [
    'JANUARI',
    'FEBRUARI',
    'MARET',
    'APRIL',
    'MEI',
    'JUNI',
    'JULI',
    'AGUSTUS',
    'SEPTEMBER',
    'OKTOBER',
    'NOVEMBER',
    'DESEMBER',
  ];

  @override
  void initState() {
    super.initState();
    progress.load();
    pet.load();
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
      return '${left.inHours} JAM';
    }
    final minutes = left.inMinutes < 1 ? 1 : left.inMinutes;
    return '$minutes MENIT';
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

  // Tanya dulu sebelum mengganti quest, karena bayar gem dan cuma bisa
  // sekali sehari.
  Future<void> rerollQuest(DailyQuest quest) async {
    final price = PlayerProgress.rerollPrice;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF20272B),
        title: const Text(
          'Ganti misi ini?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Misi "${questTitle(quest)}" akan diganti dengan misi lain secara '
          'acak. Harganya $price gem dan hanya bisa sekali sehari.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: progress.gems >= price
                ? () => Navigator.pop(context, true)
                : null,
            child: Text(
              progress.gems >= price ? 'GANTI ($price GEM)' : 'GEM KURANG',
              style: TextStyle(
                color: progress.gems >= price
                    ? const Color(0xFF1CB0F6)
                    : Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final replacement = await progress.rerollQuest(quest);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            replacement != null
                ? 'Misi baru: ${questTitle(replacement)}'
                : 'Belum ada misi pengganti yang cocok. Gem tidak terpakai.',
          ),
          backgroundColor: const Color(0xFF20272B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // Nama Quacko di judul quest mengikuti nama yang diberikan pemain.
  String questTitle(DailyQuest quest) =>
      quest.title.replaceAll('Quacko', pet.name);

  Future<void> openMonthlyChest() async {
    final loot = await showChestOpening(context, ChestTier.gold);
    if (loot == null) return;
    await progress.claimMonthly(loot);
  }

  // Sisa hari sampai quest mingguan di-reset (Senin), termasuk hari ini.
  int get weeklyDaysLeft => 8 - DateTime.now().weekday;

  Future<void> openWeeklyChest() async {
    final loot = await showChestOpening(context, ChestTier.silver);
    if (loot == null) return;
    await progress.claimWeekly(loot);
  }

  void openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void openShop() => openPage(const ShopPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      floatingActionButton: const InventoryButton(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            progress,
            pet,
            InventoryService.instance,
          ]),
          builder: (context, _) {
            if (!progress.isLoaded || !pet.isLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFE7C249)),
              );
            }

            final quests = progress.dailyQuests;
            final milestone = progress.pendingStreakMilestone;
            if (milestone != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                showStreakMilestoneDialog(milestone);
                progress.clearPendingStreakMilestone();
              });
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Misi',
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

                if (InventoryService.instance.isActive(
                  ItemEffect.unlimitedHearts,
                )) ...[
                  const SizedBox(height: 10),
                  buildHeartsBanner(),
                ],

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(child: buildPetCard()),
                    const SizedBox(width: 12),
                    Expanded(child: buildSpinCard()),
                  ],
                ),

                const SizedBox(height: 12),

                buildStreakCard(),

                const SizedBox(height: 30),

                buildMonthlyChallenge(),

                const SizedBox(height: 30),

                buildSectionHeader('Misi Harian', dailyTimeLeft),

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

                buildSectionHeader('Misi Mingguan', '$weeklyDaysLeft HARI'),

                const SizedBox(height: 12),

                buildWeeklyQuest(),
              ],
            );
          },
        ),
      ),
    );
  }

  // Kartu kecil berisi Quacko. Ditekan untuk membuka halaman pet.
  Widget buildPetCard() {
    return buildShortcutCard(
      onTap: () => openPage(const PetPage()),
      highlight: pet.mood == DuckMood.hungry || pet.mood == DuckMood.sad,
      preview: CustomPaint(
        size: const Size(64, 64),
        painter: DuckPainter(
          mood: pet.mood,
          stage: pet.stage,
          accessories: pet.equipped,
        ),
      ),
      title: '${pet.name} · Lv ${pet.level}',
      subtitle: switch (pet.mood) {
        DuckMood.happy => 'Senang banget',
        DuckMood.normal => 'Santai',
        DuckMood.hungry => 'Lapar!',
        DuckMood.sad => 'Kangen kamu',
        DuckMood.sleeping => 'Tidur',
      },
    );
  }

  Widget buildSpinCard() {
    return buildShortcutCard(
      onTap: () => openPage(const DailySpinPage()),
      highlight: progress.canSpin,
      preview: const SpinWheel(size: 64),
      title: 'Roda Harian',
      subtitle: progress.canSpin ? 'Siap diputar!' : 'Besok lagi',
    );
  }

  // [highlight] memberi garis kuning, tanda ada yang perlu dilakukan.
  Widget buildShortcutCard({
    required VoidCallback onTap,
    required bool highlight,
    required Widget preview,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlight ? const Color(0xFFE7C249) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            preview,
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: highlight ? const Color(0xFFE7C249) : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showStreakMilestoneDialog(int milestone) {
    const cardColor = Color(0xFF20272B);
    const yellowColor = Color(0xFFFCCF10);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Image.asset('assets/icons/streak.png', height: 72),
              ),
              const SizedBox(height: 14),
              Text(
                'Selamat!',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$milestone hari beruntun! +20 Gem',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellowColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OKE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Streak harian dan progress menuju target dari halaman Streak Goal.
  // Ditekan untuk membuka kalender streak.
  Widget buildStreakCard() {
    final streak = progress.streak;
    final goal = progress.streakGoal;
    final studied = progress.studiedToday;

    return GestureDetector(
      onTap: () => openPage(const StreakCalendarPage()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: studied ? 1 : 0.4,
              child: Image.asset('assets/icons/streak.png', height: 44),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$streak hari beruntun',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Terbaik: ${progress.bestStreak}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  buildProgressBar(progress.streakCycleProgress, goal),
                  const SizedBox(height: 6),
                  Text(
                    studied
                        ? 'Kamu sudah belajar hari ini. Mantap!'
                        : 'Selesaikan 1 lesson hari ini supaya tidak putus.',
                    style: TextStyle(
                      color: studied ? const Color(0xFF58CC02) : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              'XP Ganda aktif: XP 2x lipat, sisa $minutes menit',
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

  // Banner Hati Tak Terbatas yang sedang aktif dari Inventori.
  Widget buildHeartsBanner() {
    final left = InventoryService.instance.timeLeft(ItemEffect.unlimitedHearts);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF5C2F35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/hearts.png', height: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hati Tak Terbatas aktif, sisa ${left.inMinutes + 1} menit',
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
                        'TANTANGAN ${monthNames[DateTime.now().month - 1]}',
                        style: GoogleFonts.baloo2(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Petualangan Kolam Emas',
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
                            '$monthlyDaysLeft HARI',
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
                  'Selesaikan ${PlayerProgress.monthlyTarget} misi',
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
            const Icon(Icons.access_time, color: Color(0xFFE7C249), size: 16),
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
          SizedBox(
            width: 44,
            child: quest.image != null
                ? Image.asset(quest.image!, height: 40, fit: BoxFit.contain)
                : Icon(quest.iconData, color: quest.iconColor, size: 38),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        questTitle(quest),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Tombol ganti quest, hanya muncul kalau masih bisa
                    if (progress.canReroll(quest))
                      GestureDetector(
                        onTap: () => rerollQuest(quest),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.refresh,
                            color: Colors.white38,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
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

  Widget buildWeeklyQuest() {
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
            'Selesaikan ${PlayerProgress.weeklyTarget} lesson minggu ini',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Reset setiap Senin. Selesaikan untuk membuka peti perak.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildProgressBar(
                  progress.lessonsThisWeek.clamp(
                    0,
                    PlayerProgress.weeklyTarget,
                  ),
                  PlayerProgress.weeklyTarget,
                ),
              ),
              const SizedBox(width: 12),
              RewardChest(
                tier: ChestTier.silver,
                size: 40,
                state: progress.weeklyChestState,
                onTap: openWeeklyChest,
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
