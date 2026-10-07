import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/avatar_catalog.dart';
import '../services/avatar_metrics.dart';

// Gambar karakter dengan animasi:
//  - muncul dengan efek memantul saat pertama tampil,
//  - bernapas pelan (idle) kalau [bodyMotion] aktif,
//  - melompat dan mengeluarkan hati/bintang saat disentuh,
//  - mengedip (atau pipi memerah untuk karakter yang matanya terpejam).
//
// [bodyMotion] = false hanya menganimasikan wajah (kedip) dan percikan,
// badan karakter diam. Dipakai di kartu profil.
class AnimatedAvatar extends StatefulWidget {
  final AvatarCharacter character;
  final double height;
  final bool bodyMotion;

  const AnimatedAvatar({
    super.key,
    required this.character,
    required this.height,
    this.bodyMotion = true,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _Spark {
  final double dx; // arah horizontal (-1..1)
  final double delay; // 0..0.4
  final double size;
  const _Spark(this.dx, this.delay, this.size);
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  final _rng = math.Random();

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final AnimationController _tap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final AnimationController _sparks = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
  );

  List<_Spark> _burst = const [];
  Timer? _blinkTimer;

  AvatarMetrics? get _metrics => avatarMetrics[widget.character.key];
  bool get _isBunny => widget.character.key.startsWith('binbin');

  @override
  void initState() {
    super.initState();
    _enter.forward();
    _idle.repeat(reverse: true);
    _scheduleBlink();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _enter.dispose();
    _idle.dispose();
    _tap.dispose();
    _sparks.dispose();
    _blink.dispose();
    super.dispose();
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(
      Duration(milliseconds: 2200 + _rng.nextInt(2800)),
      () async {
        await _doBlink();
        if (mounted) _scheduleBlink();
      },
    );
  }

  Future<void> _doBlink() async {
    if (!mounted) return;
    try {
      await _blink.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (mounted) await _blink.reverse();
    } on TickerCanceled {
      // widget dibuang saat animasi berjalan
    }
  }

  Future<void> _onTap() async {
    _burst = List.generate(
      3,
      (i) => _Spark(
        (i - 1) * 0.55 + (_rng.nextDouble() - 0.5) * 0.3,
        i * 0.12,
        0.16 + _rng.nextDouble() * 0.06,
      ),
    );
    _tap.forward(from: 0);
    _sparks.forward(from: 0);
    await _doBlink();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _doBlink();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;
    final h = widget.height;
    final w = metrics != null ? h * metrics.aspect : h;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_enter, _idle, _tap, _sparks, _blink]),
        builder: (context, _) {
          final enter = _enter.value;
          final idle = Curves.easeInOut.transform(_idle.value);
          final t = _tap.value;

          double sx = 1, sy = 1, dy = 0, rot = 0;

          // Muncul: membesar sambil memantul
          final pop = Curves.elasticOut.transform(enter);
          sx = sy = 0.6 + 0.4 * pop;

          if (widget.bodyMotion) {
            // Bernapas
            sy *= 1 + 0.018 * idle;
            sx *= 1 - 0.008 * idle;

            if (t > 0 && t < 1) {
              // Melompat, goyang, lalu mendarat dengan efek gepeng
              dy -= math.sin(math.pi * t) * h * 0.09;
              rot = 0.07 * math.sin(math.pi * 2 * t) * (1 - t);
              double land = 0;
              if (t > 0.82) {
                land = math.sin(math.pi * (t - 0.82) / 0.18);
              } else if (t < 0.12) {
                land = math.sin(math.pi * t / 0.12);
              }
              sy *= 1 - 0.07 * land;
              sx *= 1 + 0.05 * land;
            }
          } else if (t > 0 && t < 1) {
            final p = 1 + 0.025 * math.sin(math.pi * t);
            sx *= p;
            sy *= p;
          }

          Widget body = SizedBox(
            width: w,
            height: h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.character.asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                if (metrics != null)
                  CustomPaint(
                    painter: _FacePainter(
                      metrics: metrics,
                      eyesClosed: _blink.value > 0.5,
                      blushPulse: idle,
                    ),
                  ),
              ],
            ),
          );

          body = Opacity(
            opacity: (enter * 4).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, dy),
              child: Transform.rotate(
                angle: rot,
                alignment: Alignment.bottomCenter,
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.diagonal3Values(sx, sy, 1),
                  child: body,
                ),
              ),
            ),
          );

          return SizedBox(
            width: w,
            height: h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: body),
                if (_sparks.isAnimating || _sparks.value > 0)
                  ..._burst.map((s) => _buildSpark(s, w, h)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpark(_Spark s, double w, double h) {
    final p = ((_sparks.value - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
    if (p <= 0 || p >= 1) return const SizedBox.shrink();
    final size = h * s.size;
    return Positioned(
      left: w * (0.5 + s.dx * 0.35) - size / 2,
      top: h * 0.22 - p * h * 0.28,
      child: Opacity(
        opacity: (1 - p).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.6 + 0.6 * math.sin(math.pi * p.clamp(0.0, 1.0)),
          child: Icon(
            _isBunny ? Icons.favorite_rounded : Icons.auto_awesome_rounded,
            size: size,
            color: _isBunny ? const Color(0xFFFF6F91) : const Color(0xFFFFD84A),
          ),
        ),
      ),
    );
  }
}

// Menimpa mata yang terbuka dengan mata terpejam bergaya pixel,
// atau memberi denyut pada pipi untuk karakter yang matanya sudah terpejam.
class _FacePainter extends CustomPainter {
  final AvatarMetrics metrics;
  final bool eyesClosed;
  final double blushPulse;

  const _FacePainter({
    required this.metrics,
    required this.eyesClosed,
    required this.blushPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final eye = metrics.eye;
    if (eye != null) {
      if (!eyesClosed) return;
      final r = Rect.fromLTRB(
        eye.left * size.width,
        eye.top * size.height,
        eye.right * size.width,
        eye.bottom * size.height,
      );
      final cover = r.inflate(r.width * 0.08);
      canvas.drawRect(
        cover,
        Paint()
          ..color = metrics.skin
          ..isAntiAlias = false,
      );

      // Mata terpejam berbentuk "‿" dari 5x2 kotak
      final u = r.width / 5;
      final lineTop = r.center.dy - u * 0.2;
      final paint = Paint()
        ..color = const Color(0xFF3B1E14)
        ..isAntiAlias = false;
      void cell(int cx, int cy) => canvas.drawRect(
        Rect.fromLTWH(r.left + cx * u, lineTop + cy * u, u, u),
        paint,
      );
      cell(0, 0);
      cell(1, 1);
      cell(2, 1);
      cell(3, 1);
      cell(4, 0);
      return;
    }

    for (final b in metrics.blush) {
      final r = Rect.fromLTRB(
        b.left * size.width,
        b.top * size.height,
        b.right * size.width,
        b.bottom * size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          r.inflate(r.width * 0.06),
          Radius.circular(r.height * 0.4),
        ),
        Paint()
          ..color = const Color(0xFFFF4F6B)
              .withValues(alpha: 0.18 + 0.32 * blushPulse),
      );
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.eyesClosed != eyesClosed || old.blushPulse != blushPulse;
}
