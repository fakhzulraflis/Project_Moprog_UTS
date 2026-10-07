import 'dart:math';

import 'package:flutter/material.dart';

enum PrizeType { gems, hearts, xp, xpBoost, none }

// Satu potongan di roda hadiah harian.
class SpinPrize {
  final PrizeType type;
  final int amount;
  final String label;
  final String? icon;
  final Color color;

  // Peluang keluar dalam persen. Total semua hadiah = 100.
  final int chance;

  const SpinPrize({
    required this.type,
    required this.amount,
    required this.label,
    required this.icon,
    required this.color,
    required this.chance,
  });

  // Urutan di sini sama dengan urutan potongan di roda (searah jarum jam,
  // mulai dari atas). Hadiah besar dibuat lebih jarang keluar.
  static const List<SpinPrize> all = [
    SpinPrize(
      type: PrizeType.gems,
      amount: 5,
      label: '5',
      icon: 'assets/icons/gems.png',
      color: Color(0xFF2E7D8C),
      chance: 20,
    ),
    SpinPrize(
      type: PrizeType.hearts,
      amount: 1,
      label: '+1',
      icon: 'assets/icons/hearts.png',
      color: Color(0xFF7B61FF),
      chance: 15,
    ),
    SpinPrize(
      type: PrizeType.gems,
      amount: 15,
      label: '15',
      icon: 'assets/icons/gems.png',
      color: Color(0xFFE7A33E),
      chance: 12,
    ),
    SpinPrize(
      type: PrizeType.none,
      amount: 0,
      label: 'ZONK',
      icon: null,
      color: Color(0xFF3A4449),
      chance: 15,
    ),
    SpinPrize(
      type: PrizeType.xp,
      amount: 20,
      label: '20',
      icon: 'assets/icons/xp.png',
      color: Color(0xFF2E7D8C),
      chance: 15,
    ),
    SpinPrize(
      type: PrizeType.xpBoost,
      amount: 15,
      label: '2x',
      icon: 'assets/icons/xp.png',
      color: Color(0xFF7B61FF),
      chance: 8,
    ),
    SpinPrize(
      type: PrizeType.hearts,
      amount: 2,
      label: '+2',
      icon: 'assets/icons/hearts.png',
      color: Color(0xFFE7A33E),
      chance: 10,
    ),
    SpinPrize(
      type: PrizeType.gems,
      amount: 50,
      label: '50',
      icon: 'assets/icons/gems.png',
      color: Color(0xFFFF4B4B),
      chance: 5,
    ),
  ];

  // Pilih hadiah secara acak sesuai peluangnya.
  // Contoh: angka acak 0-99, kalau hasilnya 0-19 dapat hadiah pertama,
  // 20-34 hadiah kedua, dan seterusnya.
  static int pickIndex([Random? random]) {
    final roll = (random ?? Random()).nextInt(100);
    var total = 0;
    for (var i = 0; i < all.length; i++) {
      total += all[i].chance;
      if (roll < total) return i;
    }
    return all.length - 1;
  }

  String get description {
    switch (type) {
      case PrizeType.gems:
        return '+$amount Gems';
      case PrizeType.hearts:
        return '+$amount Bonus ${amount == 1 ? 'Heart' : 'Hearts'}';
      case PrizeType.xp:
        return '+$amount XP';
      case PrizeType.xpBoost:
        return 'XP Boost $amount menit';
      case PrizeType.none:
        return 'Zonk! Coba lagi besok';
    }
  }
}

// Gambar potongan-potongan warna di roda.
class WheelPainter extends CustomPainter {
  final List<SpinPrize> prizes;

  WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final sweep = 2 * pi / prizes.length;

    // Bingkai luar
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFFFC800));

    final inner = Rect.fromCircle(center: center, radius: radius * 0.92);
    for (var i = 0; i < prizes.length; i++) {
      // Potongan ke-i berpusat di atas lalu berputar searah jarum jam
      final start = -pi / 2 + i * sweep - sweep / 2;
      canvas.drawArc(
        inner,
        start,
        sweep,
        true,
        Paint()..color = prizes[i].color,
      );
      canvas.drawArc(
        inner,
        start,
        sweep,
        true,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Lampu-lampu kecil di bingkai
    final bulb = Paint()..color = Colors.white;
    for (var i = 0; i < prizes.length * 2; i++) {
      final angle = i * pi / prizes.length;
      canvas.drawCircle(
        center + Offset(cos(angle), sin(angle)) * radius * 0.96,
        radius * 0.025,
        bulb,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) => oldDelegate.prizes != prizes;
}

// Roda lengkap: potongan warna + ikon dan tulisan hadiah.
// [rotation] dalam radian, searah jarum jam.
class SpinWheel extends StatelessWidget {
  final double size;
  final double rotation;

  const SpinWheel({super.key, required this.size, this.rotation = 0});

  @override
  Widget build(BuildContext context) {
    final prizes = SpinPrize.all;
    final sweep = 2 * pi / prizes.length;

    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            CustomPaint(size: Size(size, size), painter: WheelPainter(prizes)),

            // Tiap label diputar ke tengah potongannya masing-masing
            for (var i = 0; i < prizes.length; i++)
              Transform.rotate(
                angle: i * sweep,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: size * 0.09),
                    child: buildLabel(prizes[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(SpinPrize prize) {
    final iconSize = size * 0.08;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prize.icon != null)
          Image.asset(prize.icon!, height: iconSize)
        else
          Icon(
            Icons.sentiment_dissatisfied,
            color: Colors.white70,
            size: iconSize,
          ),
        SizedBox(height: size * 0.01),
        Text(
          prize.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.05,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
