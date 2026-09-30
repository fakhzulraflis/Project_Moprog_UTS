import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/player_progress.dart';
import '../widgets/reward_chest.dart';

// Toko untuk membelanjakan gem yang didapat dari peti quest.
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  static const Color backgroundColor = Color(0xFF272F33);
  static const Color cardColor = Color(0xFF20272B);
  static const Color gemColor = Color(0xFF1CB0F6);

  static const int xpBoostPrice = 40;
  static const int heartPackPrice = 25;
  static const int heartPackAmount = 2;
  static const int mysteryChestPrice = 30;

  final progress = PlayerProgress.instance;

  // Memperbarui sisa waktu XP Boost.
  Timer? clock;

  @override
  void initState() {
    super.initState();
    progress.load();
    clock = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    clock?.cancel();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: cardColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> buyXpBoost() async {
    final ok = await progress.buyXpBoost(xpBoostPrice);
    if (!mounted) return;
    showMessage(
      ok ? 'XP Boost aktif selama 15 menit!' : 'Gem kamu belum cukup.',
    );
  }

  Future<void> buyHeartPack() async {
    final ok = await progress.buyBonusHearts(heartPackPrice, heartPackAmount);
    if (!mounted) return;
    showMessage(
      ok
          ? '+$heartPackAmount hati tambahan di lesson berikutnya!'
          : 'Gem kamu belum cukup.',
    );
  }

  Future<void> buyMysteryChest() async {
    final ok = await progress.spendGems(mysteryChestPrice);
    if (!mounted) return;
    if (!ok) {
      showMessage('Gem kamu belum cukup.');
      return;
    }

    final loot = await showChestOpening(context, ChestTier.silver);
    if (loot != null) await progress.addLoot(loot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Shop',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          if (!progress.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: gemColor),
            );
          }

          final boostActive = progress.isXpBoostActive;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              buildBalance(),

              const SizedBox(height: 24),

              buildItem(
                icon: Image.asset('assets/icons/xp.png', height: 44),
                title: 'XP Boost',
                description: boostActive
                    ? 'Sedang aktif, sisa '
                          '${progress.xpBoostLeft.inMinutes + 1} menit.'
                    : 'XP dari lesson jadi 2x lipat selama 15 menit.',
                price: xpBoostPrice,
                enabled: !boostActive,
                onBuy: buyXpBoost,
              ),

              buildItem(
                icon: Image.asset('assets/icons/hearts.png', height: 44),
                title: 'Heart Pack',
                description:
                    '+$heartPackAmount hati tambahan di awal lesson berikutnya.'
                    '${progress.bonusHearts > 0 ? '\nTersimpan: ${progress.bonusHearts} hati' : ''}',
                price: heartPackPrice,
                onBuy: buyHeartPack,
              ),

              buildItem(
                icon: CustomPaint(
                  size: const Size(48, 43),
                  painter: ChestPainter(tier: ChestTier.silver),
                ),
                title: 'Mystery Chest',
                description: 'Peti perak berisi gem, XP, atau hati. '
                    'Isinya acak!',
                price: mysteryChestPrice,
                onBuy: buyMysteryChest,
              ),

              const SizedBox(height: 12),

              const Text(
                'Dapatkan gem dengan membuka peti dari Daily Quests.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildBalance() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/gems.png', height: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR GEMS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${progress.gems}',
                  style: GoogleFonts.baloo2(
                    color: gemColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'TOTAL XP',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${progress.totalXp}',
                style: GoogleFonts.baloo2(
                  color: const Color(0xFFE7C249),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildItem({
    required Widget icon,
    required String title,
    required String description,
    required int price,
    required VoidCallback onBuy,
    bool enabled = true,
  }) {
    final affordable = progress.gems >= price;
    final canBuy = enabled && affordable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(width: 52, child: Center(child: icon)),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: canBuy ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: gemColor,
              disabledBackgroundColor: const Color(0xFF3A4449),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white38,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/gems.png',
                  height: 16,
                  opacity: AlwaysStoppedAnimation(canBuy ? 1 : 0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  '$price',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
