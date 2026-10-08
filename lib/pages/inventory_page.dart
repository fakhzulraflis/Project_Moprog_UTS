import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_session.dart';
import '../services/inventory_service.dart';

// Halaman Inventori: barang yang didapat dari toko, peti misi, dan roda
// harian. Barang baru berefek setelah dipakai di sini.
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  static const Color backgroundColor = Color(0xFF272F33);
  static const Color cardColor = Color(0xFF20272B);
  static const Color yellowColor = Color(0xFFE7C249);

  final inventory = InventoryService.instance;

  // Memperbarui hitung mundur efek yang sedang aktif tiap detik.
  Timer? clock;

  @override
  void initState() {
    super.initState();
    inventory.load();
    clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
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

  Future<void> useItem(OwnedItem item) async {
    final error = await inventory.use(item);
    if (!mounted) return;
    final info = item.info!;
    showMessage(
      error ??
          '${ItemInfo.effectName(info.effect)} aktif sampai '
              '${formatClock(inventory.activeUntil(info.effect))}',
    );
  }

  // Panel detail barang: logo, nama, deskripsi, dan tombol PAKAI di kanan.
  void showPreview(ItemInfo info, List<OwnedItem> owned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Row(
            children: [
              ItemTile(info: info, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      info.name,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dimiliki: ${owned.length}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  useItem(owned.first);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellowColor,
                  foregroundColor: backgroundColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'PAKAI',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Jam berakhirnya efek, disesuaikan dengan jam di HP ini.
  String formatClock(DateTime? time) {
    if (time == null) return '-';
    final local = time.subtract(inventory.clockOffset).toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String formatLeft(Duration left) {
    final h = left.inHours;
    final m = (left.inMinutes % 60).toString().padLeft(2, '0');
    final s = (left.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
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
          'Inventori',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: inventory,
        builder: (context, _) {
          if (!AuthSession.instance.isLoggedIn) {
            return buildMessage(
              Icons.lock_outline,
              'Masuk ke akunmu dulu untuk melihat inventori.',
            );
          }

          if (!inventory.isLoaded) {
            if (inventory.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: yellowColor),
              );
            }
            return buildMessage(
              Icons.cloud_off,
              inventory.error ?? 'Inventori belum bisa dimuat.',
              onRetry: inventory.load,
            );
          }

          return RefreshIndicator(
            color: yellowColor,
            onRefresh: inventory.load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ...buildActiveEffects(),
                Text(
                  'Barang Kamu',
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ketuk barang untuk melihat detail dan memakainya.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 14),
                buildGrid(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> buildActiveEffects() {
    final effects = ItemEffect.values.where(inventory.isActive).toList();
    if (effects.isEmpty) return [];

    return [
      Text(
        'Sedang Aktif',
        style: GoogleFonts.baloo2(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      for (final effect in effects) buildActiveCard(effect),
      const SizedBox(height: 18),
    ];
  }

  Widget buildActiveCard(ItemEffect effect) {
    final info = ItemInfo.all.firstWhere((i) => i.effect == effect);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: info.color, width: 2),
      ),
      child: Row(
        children: [
          Image.asset(info.image, height: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ItemInfo.effectName(effect),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.timer_outlined, color: Colors.white70, size: 18),
          const SizedBox(width: 4),
          Text(
            formatLeft(inventory.timeLeft(effect)),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGrid() {
    final groups = inventory.grouped;

    if (groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(Icons.backpack_outlined, color: Colors.white38, size: 48),
            SizedBox(height: 10),
            Text(
              'Inventori masih kosong. Dapatkan barang dari Toko, peti Misi, '
              'atau Roda Harian.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        for (final group in groups)
          GestureDetector(
            onTap: () => showPreview(group.key, group.value),
            child: ItemTile(info: group.key, count: group.value.length),
          ),
      ],
    );
  }

  Widget buildMessage(IconData icon, String text, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white38, size: 56),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'COBA LAGI',
                  style: TextStyle(color: yellowColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Kotak persegi satu barang: logo, durasi di bawah, dan jumlah di pojok.
class ItemTile extends StatelessWidget {
  final ItemInfo info;
  final int count;
  final double? size;

  const ItemTile({super.key, required this.info, this.count = 1, this.size});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: info.color, width: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 14),
              child: FractionallySizedBox(
                widthFactor: 0.42,
                heightFactor: 0.42,
                child: Image.asset(info.image, fit: BoxFit.contain),
              ),
            ),
          ),
          // Tanda efek: 2x untuk XP Ganda, ∞ untuk Hati Tak Terbatas
          Positioned(
            left: 4,
            top: 2,
            child: Text(
              info.effect == ItemEffect.xpBoost ? '2x' : '∞',
              style: TextStyle(
                color: info.color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 4,
            child: Text(
              info.shortDuration,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (count > 1)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: info.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'x$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return size == null
        ? tile
        : SizedBox(width: size, height: size, child: tile);
  }
}
