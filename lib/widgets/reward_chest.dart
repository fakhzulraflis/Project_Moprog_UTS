import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tingkatan peti. Makin tinggi tingkatnya, makin besar isinya.
enum ChestTier { bronze, silver, gold }

// Keadaan peti di daftar quest.
// locked  = quest belum selesai
// ready   = quest selesai, peti bisa dibuka
// claimed = hadiah sudah diambil
enum ChestState { locked, ready, claimed }

class ChestColors {
  final Color light;
  final Color base;
  final Color dark;
  final Color trim;

  const ChestColors(this.light, this.base, this.dark, this.trim);

  static ChestColors of(ChestTier tier) {
    switch (tier) {
      case ChestTier.bronze:
        return const ChestColors(
          Color(0xFFE39A5B),
          Color(0xFFC0703A),
          Color(0xFF7A4020),
          Color(0xFFF3C58F),
        );
      case ChestTier.silver:
        return const ChestColors(
          Color(0xFFE6EDF2),
          Color(0xFFB4C1CA),
          Color(0xFF6F7E88),
          Color(0xFFFFFFFF),
        );
      case ChestTier.gold:
        return const ChestColors(
          Color(0xFFFFE27A),
          Color(0xFFF2B927),
          Color(0xFFB07D0C),
          Color(0xFFFFF4C2),
        );
    }
  }
}

// Jenis hadiah yang bisa keluar dari peti.
enum LootType { gems, xp, hearts }

// Isi peti setelah dibuka.
class ChestLoot {
  final LootType type;
  final int amount;

  const ChestLoot(this.type, this.amount);

  String get icon {
    switch (type) {
      case LootType.gems:
        return 'assets/icons/gems.png';
      case LootType.xp:
        return 'assets/icons/xp.png';
      case LootType.hearts:
        return 'assets/icons/hearts.png';
    }
  }

  String get label {
    switch (type) {
      case LootType.gems:
        return 'Gem';
      case LootType.xp:
        return 'XP';
      case LootType.hearts:
        return 'Hati Bonus';
    }
  }

  // Isi peti diacak. Peti emas selalu lebih besar dari perak,
  // perak selalu lebih besar dari perunggu.
  static ChestLoot roll(ChestTier tier, [Random? random]) {
    final rng = random ?? Random();

    // [minGem, maxGem, minXp, maxXp, hati]
    const table = {
      ChestTier.bronze: [5, 10, 10, 20, 1],
      ChestTier.silver: [15, 25, 25, 40, 2],
      ChestTier.gold: [40, 60, 60, 100, 5],
    };
    final t = table[tier]!;

    switch (rng.nextInt(3)) {
      case 0:
        return ChestLoot(LootType.gems, t[0] + rng.nextInt(t[1] - t[0] + 1));
      case 1:
        return ChestLoot(LootType.xp, t[2] + rng.nextInt(t[3] - t[2] + 1));
      default:
        return ChestLoot(LootType.hearts, t[4]);
    }
  }
}

String chestName(ChestTier tier) {
  switch (tier) {
    case ChestTier.bronze:
      return 'Peti Perunggu';
    case ChestTier.silver:
      return 'Peti Perak';
    case ChestTier.gold:
      return 'Peti Emas';
  }
}

// Gambar peti. Digambar pakai CustomPainter supaya satu kode bisa
// dipakai untuk tiga warna, tanpa perlu file gambar baru.
class ChestPainter extends CustomPainter {
  final ChestTier tier;
  final bool isOpen;

  ChestPainter({required this.tier, this.isOpen = false});

  @override
  void paint(Canvas canvas, Size size) {
    final c = ChestColors.of(tier);
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // Bayangan di bawah peti
    paint.color = Colors.black26;
    canvas.drawOval(Rect.fromLTRB(w * 0.08, h * 0.88, w * 0.92, h), paint);

    if (isOpen) {
      // Tutup terbuka ke belakang: yang kelihatan sisi dalamnya,
      // bentuknya melebar ke atas seperti dilihat dari depan
      final lid = Path()
        ..moveTo(w * 0.10, h * 0.44)
        ..lineTo(w * 0.02, h * 0.10)
        ..quadraticBezierTo(w * 0.50, h * -0.04, w * 0.98, h * 0.10)
        ..lineTo(w * 0.90, h * 0.44)
        ..close();
      paint.color = c.base;
      canvas.drawPath(lid, paint);

      final lidInside = Path()
        ..moveTo(w * 0.16, h * 0.44)
        ..lineTo(w * 0.10, h * 0.15)
        ..quadraticBezierTo(w * 0.50, h * 0.04, w * 0.90, h * 0.15)
        ..lineTo(w * 0.84, h * 0.44)
        ..close();
      paint.color = c.dark;
      canvas.drawPath(lidInside, paint);
    }

    // Badan peti
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.06, h * 0.46, w * 0.94, h * 0.94),
      Radius.circular(w * 0.08),
    );
    paint.color = c.base;
    canvas.drawRRect(body, paint);

    // Bagian bawah badan sedikit lebih gelap supaya kelihatan bervolume
    paint.color = c.dark.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(w * 0.06, h * 0.78, w * 0.94, h * 0.94),
        bottomLeft: Radius.circular(w * 0.08),
        bottomRight: Radius.circular(w * 0.08),
      ),
      paint,
    );

    if (isOpen) {
      // Rongga peti yang gelap, dengan kilau harta di dalamnya
      final inside = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.12, h * 0.46, w * 0.88, h * 0.60),
        Radius.circular(w * 0.04),
      );
      paint.color = Colors.black.withValues(alpha: 0.45);
      canvas.drawRRect(inside, paint);
      paint.color = c.trim.withValues(alpha: 0.8);
      canvas.drawOval(
        Rect.fromLTRB(w * 0.30, h * 0.48, w * 0.70, h * 0.56),
        paint,
      );

      // Bibir depan peti
      paint.color = c.dark;
      canvas.drawRect(
        Rect.fromLTRB(w * 0.06, h * 0.60, w * 0.94, h * 0.65),
        paint,
      );
    } else {
      // Tutup peti
      final lid = RRect.fromRectAndCorners(
        Rect.fromLTRB(w * 0.06, h * 0.12, w * 0.94, h * 0.48),
        topLeft: Radius.circular(w * 0.22),
        topRight: Radius.circular(w * 0.22),
        bottomLeft: Radius.circular(w * 0.03),
        bottomRight: Radius.circular(w * 0.03),
      );
      paint.color = c.light;
      canvas.drawRRect(lid, paint);

      // Kilau di tutup
      paint.color = Colors.white.withValues(alpha: 0.35);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.36, h * 0.17, w * 0.64, h * 0.22),
          Radius.circular(w * 0.03),
        ),
        paint,
      );

      // Garis sambungan tutup dan badan
      paint.color = c.dark;
      canvas.drawRect(
        Rect.fromLTRB(w * 0.06, h * 0.45, w * 0.94, h * 0.50),
        paint,
      );
    }

    // Dua sabuk logam kiri dan kanan
    paint.color = c.dark;
    final strapTop = isOpen ? h * 0.60 : h * 0.12;
    for (final x in [w * 0.20, w * 0.70]) {
      canvas.drawRect(
        Rect.fromLTRB(x, strapTop, x + w * 0.10, h * 0.94),
        paint,
      );
    }

    // Gembok di tengah (hanya kalau peti masih tertutup)
    if (!isOpen) {
      final lock = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.39, h * 0.38, w * 0.61, h * 0.64),
        Radius.circular(w * 0.05),
      );
      paint.color = c.dark;
      canvas.drawRRect(lock.inflate(w * 0.02), paint);
      paint.color = c.trim;
      canvas.drawRRect(lock, paint);

      paint.color = c.dark;
      canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.04, paint);
      canvas.drawRect(
        Rect.fromLTRB(w * 0.485, h * 0.48, w * 0.515, h * 0.58),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ChestPainter oldDelegate) =>
      oldDelegate.tier != tier || oldDelegate.isOpen != isOpen;
}

// Peti kecil yang tampil di samping progress bar quest.
// Kalau sudah bisa diklaim, peti memantul supaya menarik perhatian.
class RewardChest extends StatefulWidget {
  final ChestTier tier;
  final ChestState state;
  final double size;
  final VoidCallback? onTap;

  const RewardChest({
    super.key,
    required this.tier,
    required this.state,
    this.size = 40,
    this.onTap,
  });

  @override
  State<RewardChest> createState() => _RewardChestState();
}

class _RewardChestState extends State<RewardChest>
    with SingleTickerProviderStateMixin {
  late final AnimationController bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    updateBounce();
  }

  @override
  void didUpdateWidget(RewardChest oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateBounce();
  }

  void updateBounce() {
    if (widget.state == ChestState.ready) {
      bounce.repeat(reverse: true);
    } else {
      bounce.stop();
      bounce.value = 0;
    }
  }

  @override
  void dispose() {
    bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chest = CustomPaint(
      size: Size(widget.size, widget.size * 0.9),
      painter: ChestPainter(
        tier: widget.tier,
        isOpen: widget.state == ChestState.claimed,
      ),
    );

    return GestureDetector(
      onTap: widget.state == ChestState.ready ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: bounce,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -4 * Curves.easeOut.transform(bounce.value)),
          child: child,
        ),
        child: switch (widget.state) {
          // Peti terkunci dibuat pudar supaya beda dengan yang siap dibuka
          ChestState.locked => Opacity(opacity: 0.4, child: chest),
          ChestState.claimed => Opacity(opacity: 0.5, child: chest),
          ChestState.ready => DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ChestColors.of(widget.tier).light
                      .withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: chest,
          ),
        },
      ),
    );
  }
}

// Layar buka peti: peti bergoyang, terbuka, lalu isinya muncul.
// Mengembalikan isi peti kalau tombol CLAIM ditekan.
Future<ChestLoot?> showChestOpening(BuildContext context, ChestTier tier) {
  return showGeneralDialog<ChestLoot>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xFF272F33),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ChestOpeningScreen(tier: tier, loot: ChestLoot.roll(tier));
    },
  );
}

class ChestOpeningScreen extends StatefulWidget {
  final ChestTier tier;
  final ChestLoot loot;

  const ChestOpeningScreen({super.key, required this.tier, required this.loot});

  @override
  State<ChestOpeningScreen> createState() => _ChestOpeningScreenState();
}

class _ChestOpeningScreenState extends State<ChestOpeningScreen>
    with SingleTickerProviderStateMixin {
  // 0.0 - 0.55 : peti bergoyang
  // 0.55       : tutup terbuka
  // 0.55 - 1.0 : hadiah membesar dari dalam peti
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  static const double openAt = 0.55;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ChestColors.of(widget.tier);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            final opened = t >= openAt;

            // Goyangan makin kencang menjelang terbuka
            final shake = opened ? 0.0 : sin(t * 60) * 0.12 * (t / openAt);

            final lootProgress = opened
                ? Curves.elasticOut.transform((t - openAt) / (1 - openAt))
                : 0.0;

            return Column(
              children: [
                const Spacer(),

                Text(
                  chestName(widget.tier),
                  style: GoogleFonts.baloo2(
                    color: colors.light,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cahaya di belakang peti setelah terbuka
                      if (opened)
                        Container(
                          width: 220 * lootProgress.clamp(0.0, 1.0),
                          height: 220 * lootProgress.clamp(0.0, 1.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.base.withValues(alpha: 0.45),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                        ),

                      Positioned(
                        bottom: 0,
                        child: Transform.rotate(
                          angle: shake,
                          child: CustomPaint(
                            size: const Size(170, 153),
                            painter: ChestPainter(
                              tier: widget.tier,
                              isOpen: opened,
                            ),
                          ),
                        ),
                      ),

                      // Hadiah naik dari dalam peti
                      if (opened)
                        Positioned(
                          top: 30 * (1 - lootProgress).clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: lootProgress,
                            child: buildLoot(),
                          ),
                        ),
                    ],
                  ),
                ),

                const Spacer(),

                AnimatedOpacity(
                  opacity: t >= 1 ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: t >= 1
                            ? () => Navigator.of(context).pop(widget.loot)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFCCF10),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'AMBIL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildLoot() {
    return Column(
      children: [
        Image.asset(widget.loot.icon, height: 64),
        const SizedBox(height: 6),
        Text(
          '+${widget.loot.amount} ${widget.loot.label}',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
