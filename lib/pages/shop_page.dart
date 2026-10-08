import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/inventory_page.dart';
import '../services/inventory_service.dart';
import '../services/player_progress.dart';
import '../widgets/inventory_button.dart';
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

  // Barang inventory yang dijual: [kunci barang, harga]
  static const List<(String, int)> inventoryItems = [
    ('xp_boost_15', 40),
    ('unlimited_hearts_30', 60),
  ];
  static const int heartPackPrice = 25;
  static const int heartPackAmount = 2;
  static const int mysteryChestPrice = 30;

  final progress = PlayerProgress.instance;

  @override
  void initState() {
    super.initState();
    progress.load();
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

  // Barang inventory tidak langsung aktif. Masuk ke Inventori dulu, lalu
  // user sendiri yang memilih kapan memakainya.
  Future<void> buyInventoryItem(ItemInfo info, int price) async {
    final error = await progress.buyItem(info.key, price);
    if (!mounted) return;
    showMessage(error ?? '${info.name} masuk ke Inventori!');
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
    final ok = await progress.buyMysteryChest(mysteryChestPrice);
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
      floatingActionButton: const InventoryButton(),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Toko',
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              buildBalance(),

              const SizedBox(height: 24),

              for (final (key, price) in inventoryItems)
                buildItem(
                  icon: ItemTile(info: ItemInfo.of(key)!, size: 56),
                  title: ItemInfo.of(key)!.name,
                  description:
                      '${ItemInfo.of(key)!.description} Masuk ke Inventori, '
                      'pakai kapan saja.',
                  price: price,
                  onBuy: () => buyInventoryItem(ItemInfo.of(key)!, price),
                ),

              buildItem(
                icon: Image.asset('assets/icons/hearts.png', height: 44),
                title: 'Paket Hati',
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
                title: 'Peti Misteri',
                description:
                    'Peti perak berisi gem, XP, hati, atau barang '
                    'Inventori. Isinya acak!',
                price: mysteryChestPrice,
                onBuy: buyMysteryChest,
              ),

              const SizedBox(height: 12),

              const Text(
                'Dapatkan gem dengan membuka peti dari Misi Harian.',
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
                  'GEM KAMU',
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
