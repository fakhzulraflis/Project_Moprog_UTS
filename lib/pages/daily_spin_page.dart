import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/player_progress.dart';
import '../widgets/spin_wheel.dart';

// Roda hadiah harian: bisa diputar sekali sehari.
class DailySpinPage extends StatefulWidget {
  const DailySpinPage({super.key});

  @override
  State<DailySpinPage> createState() => _DailySpinPageState();
}

class _DailySpinPageState extends State<DailySpinPage>
    with SingleTickerProviderStateMixin {
  static const Color backgroundColor = Color(0xFF272F33);
  static const Color cardColor = Color(0xFF20272B);
  static const Color yellowColor = Color(0xFFFCCF10);

  final progress = PlayerProgress.instance;

  late final AnimationController spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  // Posisi roda (radian) sebelum dan sesudah diputar
  double startRotation = 0;
  double endRotation = 0;

  bool isSpinning = false;

  // Memperbarui hitung mundur sampai roda bisa diputar lagi.
  Timer? clock;

  static double get sweep => 2 * pi / SpinPrize.all.length;

  // Sudut roda supaya potongan ke-[index] tepat di bawah penunjuk (atas).
  static double angleFor(int index) => (2 * pi - index * sweep) % (2 * pi);

  @override
  void initState() {
    super.initState();
    progress.load().then((_) {
      // Kalau hari ini sudah memutar, roda langsung menunjuk hadiahnya
      if (mounted && !progress.canSpin && progress.lastSpinPrize >= 0) {
        setState(() {
          startRotation = endRotation = angleFor(progress.lastSpinPrize);
        });
      }
    });
    clock = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    clock?.cancel();
    spin.dispose();
    super.dispose();
  }

  double get rotation {
    final t = Curves.easeOutCubic.transform(spin.value);
    return startRotation + (endRotation - startRotation) * t;
  }

  Future<void> spinWheel() async {
    if (isSpinning || !progress.canSpin) return;

    // Hadiah ditentukan dan disimpan dulu, baru rodanya berputar
    final index = SpinPrize.pickIndex();
    final ok = await progress.claimSpin(index);
    if (!ok || !mounted) return;

    // Berhenti sedikit acak di dalam potongan supaya terlihat alami
    final jitter = (Random().nextDouble() - 0.5) * sweep * 0.6;
    final current = rotation % (2 * pi);
    final toTarget = (angleFor(index) - current) % (2 * pi);

    setState(() {
      isSpinning = true;
      startRotation = current;
      endRotation = current + 6 * 2 * pi + toTarget + jitter;
    });

    await spin.forward(from: 0);
    if (!mounted) return;
    setState(() => isSpinning = false);
    showResult(SpinPrize.all[index]);
  }

  void showResult(SpinPrize prize) {
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
                child: prize.icon != null
                    ? Image.asset(prize.icon!, height: 72)
                    : const Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.white54,
                        size: 72,
                      ),
              ),
              const SizedBox(height: 14),
              Text(
                prize.type == PrizeType.none ? 'Yah...' : 'Selamat!',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                prize.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              if (prize.type == PrizeType.xpBoost)
                const Text(
                  'Masuk ke Inventori, pakai kapan saja',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13),
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
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get nextSpinIn {
    final now = DateTime.now();
    final left = DateTime(now.year, now.month, now.day + 1).difference(now);
    final minutes = left.inMinutes % 60;
    return left.inHours > 0
        ? '${left.inHours} jam $minutes menit'
        : '${max(1, left.inMinutes)} menit';
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
          'Roda Harian',
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
              child: CircularProgressIndicator(color: yellowColor),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Putar sekali sehari, gratis! Hadiah langsung masuk ke '
                'saldo kamu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              buildWheel(),
              const SizedBox(height: 24),
              buildStatus(),
              const SizedBox(height: 24),
              buildChanceTable(),
            ],
          );
        },
      ),
    );
  }

  Widget buildWheel() {
    const size = 290.0;
    final canSpin = progress.canSpin && !isSpinning;

    return Center(
      child: SizedBox(
        width: size,
        height: size + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 16,
              child: AnimatedBuilder(
                animation: spin,
                builder: (context, _) =>
                    SpinWheel(size: size, rotation: rotation),
              ),
            ),

            // Penunjuk di atas roda
            Positioned(
              top: 0,
              child: CustomPaint(
                size: const Size(34, 38),
                painter: PointerPainter(),
              ),
            ),

            // Tombol putar di tengah roda
            Positioned(
              top: 16 + size / 2 - 38,
              child: GestureDetector(
                onTap: canSpin ? spinWheel : null,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: canSpin ? yellowColor : const Color(0xFF3A4449),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 8),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'PUTAR',
                    style: TextStyle(
                      color: canSpin ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatus() {
    final String title;
    final String subtitle;

    if (isSpinning) {
      title = 'Rodanya berputar...';
      subtitle = 'Semoga dapat hadiah besar!';
    } else if (progress.canSpin) {
      title = 'Roda siap diputar!';
      subtitle = 'Tekan tombol PUTAR di tengah roda.';
    } else {
      final prize = progress.lastSpinPrize >= 0
          ? SpinPrize.all[progress.lastSpinPrize].description
          : '-';
      title = 'Hadiah hari ini: $prize';
      subtitle = 'Putar lagi dalam $nextSpinIn.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Daftar peluang tiap hadiah, supaya pemain tahu kesempatannya.
  Widget buildChanceTable() {
    final prizes = [...SpinPrize.all]
      ..sort((a, b) => b.chance.compareTo(a.chance));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PELUANG HADIAH',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          for (final prize in prizes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: prize.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prize.description,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(
                    '${prize.chance}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Segitiga penunjuk di atas roda.
class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFF4B4B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(PointerPainter oldDelegate) => false;
}
