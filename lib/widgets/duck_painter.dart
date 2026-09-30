import 'dart:math';

import 'package:flutter/material.dart';

// Suasana hati Quacko. Menentukan ekspresi wajah yang digambar.
enum DuckMood { happy, normal, hungry, sad, sleeping }

// Aksesoris yang bisa dipakai Quacko. Aksesoris dengan slot yang sama
// tidak bisa dipakai bersamaan (misalnya topi pesta dan mahkota).
enum DuckAccessory {
  partyHat('head'),
  crown('head'),
  sunglasses('eyes'),
  scarf('neck');

  final String slot;
  const DuckAccessory(this.slot);
}

// Gambar Quacko, anak bebek maskot aplikasi. Digambar pakai CustomPainter
// supaya ekspresi dan aksesorisnya bisa berubah sesuai data.
class DuckPainter extends CustomPainter {
  final DuckMood mood;
  final Set<DuckAccessory> accessories;

  // 0.0 - 1.0, dipakai untuk mengepakkan sayap waktu senang
  final double wingFlap;

  DuckPainter({
    required this.mood,
    this.accessories = const {},
    this.wingFlap = 0,
  });

  static const Color yellow = Color(0xFFFFD43B);
  static const Color yellowDark = Color(0xFFF2B01E);
  static const Color belly = Color(0xFFFFEB99);
  static const Color orange = Color(0xFFFF9A1F);
  static const Color orangeDark = Color(0xFFE0700F);
  static const Color eye = Color(0xFF3B2A20);
  static const Color cheek = Color(0xFFFF8A8A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // Bayangan di bawah kaki
    paint.color = Colors.black.withValues(alpha: 0.25);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.95),
        width: w * 0.55,
        height: h * 0.06,
      ),
      paint,
    );

    // Kaki
    paint.color = orange;
    for (final x in [0.38, 0.62]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * x, h * 0.92),
          width: w * 0.18,
          height: h * 0.07,
        ),
        paint,
      );
    }

    // Sayap (di belakang badan). Waktu senang, sayap mengepak.
    final flap = mood == DuckMood.happy ? sin(wingFlap * pi) * 0.5 : 0.0;
    paint.color = yellowDark;
    for (final side in [-1, 1]) {
      canvas.save();
      canvas.translate(w * (0.5 + side * 0.27), h * 0.62);
      canvas.rotate(side * (0.5 + flap));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, h * 0.08),
          width: w * 0.16,
          height: h * 0.24,
        ),
        paint,
      );
      canvas.restore();
    }

    // Badan dan perut
    paint.color = yellow;
    canvas.drawOval(
      Rect.fromLTRB(w * 0.22, h * 0.48, w * 0.78, h * 0.93),
      paint,
    );
    paint.color = belly;
    canvas.drawOval(
      Rect.fromLTRB(w * 0.34, h * 0.60, w * 0.66, h * 0.90),
      paint,
    );

    if (accessories.contains(DuckAccessory.scarf)) drawScarf(canvas, w, h);

    // Jambul di atas kepala
    paint.color = yellow;
    final tuft = Path()
      ..moveTo(w * 0.45, h * 0.14)
      ..quadraticBezierTo(w * 0.44, h * 0.03, w * 0.52, h * 0.05)
      ..quadraticBezierTo(w * 0.50, h * 0.09, w * 0.56, h * 0.08)
      ..quadraticBezierTo(w * 0.56, h * 0.12, w * 0.55, h * 0.14)
      ..close();
    canvas.drawPath(tuft, paint);

    // Kepala
    canvas.drawCircle(Offset(w * 0.5, h * 0.34), w * 0.25, paint);

    // Pipi merah
    paint.color = cheek.withValues(alpha: 0.55);
    for (final x in [0.33, 0.67]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * x, h * 0.41),
          width: w * 0.09,
          height: h * 0.05,
        ),
        paint,
      );
    }

    drawEyes(canvas, w, h);
    drawBeak(canvas, w, h);

    if (accessories.contains(DuckAccessory.sunglasses)) {
      drawSunglasses(canvas, w, h);
    }
    if (accessories.contains(DuckAccessory.partyHat)) {
      drawPartyHat(canvas, w, h);
    }
    if (accessories.contains(DuckAccessory.crown)) {
      drawCrown(canvas, w, h);
    }
  }

  void drawEyes(Canvas canvas, double w, double h) {
    final paint = Paint()..color = eye;
    final line = Paint()
      ..color = eye
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;

    for (final x in [0.41, 0.59]) {
      final c = Offset(w * x, h * 0.33);
      switch (mood) {
        case DuckMood.happy:
          // Mata tersenyum ^ ^
          canvas.drawArc(
            Rect.fromCenter(
              center: c.translate(0, h * 0.015),
              width: w * 0.08,
              height: h * 0.07,
            ),
            pi,
            pi,
            false,
            line,
          );
        case DuckMood.sleeping:
          // Mata terpejam
          canvas.drawArc(
            Rect.fromCenter(
              center: c.translate(0, -h * 0.01),
              width: w * 0.08,
              height: h * 0.05,
            ),
            0,
            pi,
            false,
            line,
          );
        case DuckMood.normal:
        case DuckMood.hungry:
        case DuckMood.sad:
          canvas.drawOval(
            Rect.fromCenter(center: c, width: w * 0.065, height: h * 0.085),
            paint,
          );
          // Kilau di mata
          canvas.drawCircle(
            c.translate(w * 0.012, -h * 0.018),
            w * 0.013,
            Paint()..color = Colors.white,
          );
      }
    }

    if (mood == DuckMood.sad) {
      // Alis turun dan air mata
      final brow = Paint()
        ..color = yellowDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round;
      // Ujung alis bagian dalam lebih tinggi, jadi kelihatan sedih
      canvas.drawLine(
        Offset(w * 0.36, h * 0.275),
        Offset(w * 0.45, h * 0.245),
        brow,
      );
      canvas.drawLine(
        Offset(w * 0.64, h * 0.275),
        Offset(w * 0.55, h * 0.245),
        brow,
      );

      final tear = Path()
        ..moveTo(w * 0.61, h * 0.38)
        ..quadraticBezierTo(w * 0.585, h * 0.43, w * 0.61, h * 0.44)
        ..quadraticBezierTo(w * 0.635, h * 0.43, w * 0.61, h * 0.38);
      canvas.drawPath(tear, Paint()..color = const Color(0xFF6EC6FF));
    }
  }

  void drawBeak(Canvas canvas, double w, double h) {
    final paint = Paint();
    final open = mood == DuckMood.hungry;

    if (open) {
      // Paruh terbuka, minta makan
      paint.color = const Color(0xFF8C2F1B);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.45),
          width: w * 0.13,
          height: h * 0.07,
        ),
        paint,
      );
      paint.color = orangeDark;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.48),
          width: w * 0.17,
          height: h * 0.05,
        ),
        paint,
      );
    } else {
      paint.color = orangeDark;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.45),
          width: w * 0.16,
          height: h * 0.05,
        ),
        paint,
      );
    }

    paint.color = orange;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, open ? h * 0.415 : h * 0.425),
        width: w * 0.2,
        height: h * 0.06,
      ),
      paint,
    );
  }

  void drawScarf(Canvas canvas, double w, double h) {
    final paint = Paint()..color = const Color(0xFFE53935);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.30, h * 0.53, w * 0.70, h * 0.60),
        Radius.circular(w * 0.04),
      ),
      paint,
    );
    // Ujung syal yang menjuntai
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.56, h * 0.56, w * 0.64, h * 0.72),
        Radius.circular(w * 0.03),
      ),
      paint,
    );
    paint.color = Colors.white.withValues(alpha: 0.5);
    for (final y in [0.62, 0.67]) {
      canvas.drawRect(
        Rect.fromLTRB(w * 0.56, h * y, w * 0.64, h * (y + 0.015)),
        paint,
      );
    }
  }

  void drawSunglasses(Canvas canvas, double w, double h) {
    final paint = Paint()..color = const Color(0xFF1B1B1B);
    for (final x in [0.40, 0.60]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * x, h * 0.335),
            width: w * 0.15,
            height: h * 0.09,
          ),
          Radius.circular(w * 0.03),
        ),
        paint,
      );
    }
    canvas.drawRect(
      Rect.fromLTRB(w * 0.46, h * 0.32, w * 0.54, h * 0.335),
      paint,
    );
    paint.color = Colors.white.withValues(alpha: 0.35);
    for (final x in [0.37, 0.57]) {
      canvas.drawRect(
        Rect.fromLTWH(w * x, h * 0.305, w * 0.04, h * 0.015),
        paint,
      );
    }
  }

  void drawPartyHat(Canvas canvas, double w, double h) {
    final hat = Path()
      ..moveTo(w * 0.40, h * 0.13)
      ..lineTo(w * 0.62, h * 0.13)
      ..lineTo(w * 0.53, h * -0.08)
      ..close();

    canvas.drawPath(hat, Paint()..color = const Color(0xFF7B61FF));

    // Garis-garis di topi
    canvas.save();
    canvas.clipPath(hat);
    final stripe = Paint()..color = const Color(0xFF58CC02);
    for (final y in [0.0, 0.07]) {
      canvas.drawRect(Rect.fromLTRB(0, h * y, w, h * (y + 0.03)), stripe);
    }
    canvas.restore();

    canvas.drawCircle(
      Offset(w * 0.53, h * -0.08),
      w * 0.035,
      Paint()..color = const Color(0xFFFF4B4B),
    );
  }

  void drawCrown(Canvas canvas, double w, double h) {
    final crown = Path()
      ..moveTo(w * 0.36, h * 0.15)
      ..lineTo(w * 0.36, h * 0.03)
      ..lineTo(w * 0.43, h * 0.09)
      ..lineTo(w * 0.50, h * 0.00)
      ..lineTo(w * 0.57, h * 0.09)
      ..lineTo(w * 0.64, h * 0.03)
      ..lineTo(w * 0.64, h * 0.15)
      ..close();
    canvas.drawPath(crown, Paint()..color = const Color(0xFFFFC800));
    canvas.drawPath(
      crown,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012,
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.115),
      w * 0.022,
      Paint()..color = const Color(0xFFFF4B4B),
    );
  }

  @override
  bool shouldRepaint(DuckPainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.wingFlap != wingFlap ||
      !setEquals(oldDelegate.accessories, accessories);

  static bool setEquals<T>(Set<T> a, Set<T> b) =>
      a.length == b.length && a.containsAll(b);
}
