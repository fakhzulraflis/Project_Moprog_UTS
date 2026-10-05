import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animasi gems berhamburan dari satu titik lalu terbang ke titik tujuan.
/// Digambar lewat Overlay, jadi bebas dari scroll/zoom halaman.
class GemBurst {
  GemBurst._();

  static void play({
    required BuildContext context,
    required Offset from, // koordinat global (layar)
    required Offset to, // koordinat global (layar)
    required String asset,
    int count = 10,
    double size = 24,
    double burstRadius = 70,
    Duration duration = const Duration(milliseconds: 1600),
    VoidCallback? onGemArrive, // dipanggil tiap gem sampai
    VoidCallback? onDone,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);

    // Cadangan: tanpa overlay, langsung anggap semua gem sampai
    if (overlay == null) {
      for (int i = 0; i < count; i++) {
        onGemArrive?.call();
      }
      onDone?.call();
      return;
    }

    // koordinat global -> koordinat overlay
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final start = overlayBox != null ? overlayBox.globalToLocal(from) : from;
    final end = overlayBox != null ? overlayBox.globalToLocal(to) : to;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _GemBurstLayer(
        from: start,
        to: end,
        asset: asset,
        count: count,
        size: size,
        burstRadius: burstRadius,
        duration: duration,
        onGemArrive: onGemArrive,
        onFinished: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            entry.remove();
            onDone?.call();
          });
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _Gem {
  final double delay; // 0..0.28 dari total waktu
  final Offset burst; // arah & jarak lontaran
  final double sway; // lengkungan saat terbang ke tujuan

  const _Gem(this.delay, this.burst, this.sway);
}

class _GemBurstLayer extends StatefulWidget {
  final Offset from;
  final Offset to;
  final String asset;
  final int count;
  final double size;
  final double burstRadius;
  final Duration duration;
  final VoidCallback? onGemArrive;
  final VoidCallback onFinished;

  const _GemBurstLayer({
    required this.from,
    required this.to,
    required this.asset,
    required this.count,
    required this.size,
    required this.burstRadius,
    required this.duration,
    required this.onGemArrive,
    required this.onFinished,
  });

  @override
  State<_GemBurstLayer> createState() => _GemBurstLayerState();
}

class _GemBurstLayerState extends State<_GemBurstLayer>
    with SingleTickerProviderStateMixin {
  static const double popEnd = 0.35; // porsi waktu fase "melontar"
  static const double life = 0.72; // lama hidup tiap gem (dari total waktu)

  late final AnimationController _c;
  late final List<_Gem> _gems;
  final Set<int> _arrived = {};

  @override
  void initState() {
    super.initState();

    final rnd = math.Random();
    final delays = List<double>.generate(
      widget.count,
      (i) => i / widget.count * (1 - life),
    )..shuffle(rnd);

    _gems = List.generate(widget.count, (i) {
      // sebar di setengah lingkaran atas
      final t = widget.count == 1 ? 0.5 : i / (widget.count - 1);
      final angle =
          math.pi * (-0.92 + 0.84 * t) + (rnd.nextDouble() - 0.5) * 0.25;
      final radius = widget.burstRadius * (0.65 + rnd.nextDouble() * 0.45);
      final sway = (rnd.nextBool() ? 1 : -1) * (20 + rnd.nextDouble() * 25);

      return _Gem(
        delays[i],
        Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        sway,
      );
    });

    _c = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(_checkArrivals)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onFinished();
      })
      ..forward();
  }

  void _checkArrivals() {
    for (int i = 0; i < _gems.length; i++) {
      final u = (_c.value - _gems[i].delay) / life;
      if (u >= 1.0 && !_arrived.contains(i)) {
        _arrived.add(i);
        widget.onGemArrive?.call();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Offset _positionOf(_Gem g, double u) {
    final burstPos = widget.from + g.burst;

    if (u < popEnd) {
      final p = Curves.easeOutCubic.transform(u / popEnd);
      return Offset.lerp(widget.from, burstPos, p)!;
    }

    final q = (u - popEnd) / (1 - popEnd);
    final e = Curves.easeInCubic.transform(q);
    final base = Offset.lerp(burstPos, widget.to, e)!;
    return base + Offset(math.sin(math.pi * q) * g.sway, 0);
  }

  double _scaleOf(double u) {
    if (u < popEnd) {
      return 0.2 + 0.8 * Curves.easeOutBack.transform(u / popEnd);
    }
    final q = (u - popEnd) / (1 - popEnd);
    return 1.0 - 0.35 * q;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final children = <Widget>[];

          for (final g in _gems) {
            final u = (_c.value - g.delay) / life;
            if (u <= 0 || u >= 1) continue; // belum mulai / sudah sampai

            final pos = _positionOf(g, u);
            final opacity = (1.0 - ((u - 0.92) / 0.08)).clamp(0.0, 1.0);

            children.add(
              Positioned(
                left: pos.dx - widget.size / 2,
                top: pos.dy - widget.size / 2,
                child: Opacity(
                  opacity: opacity.toDouble(),
                  child: Transform.scale(
                    scale: _scaleOf(u),
                    child: Image.asset(
                      widget.asset,
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.diamond_rounded,
                        size: widget.size,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: children,
          );
        },
      ),
    );
  }
}
