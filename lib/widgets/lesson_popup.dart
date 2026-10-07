import 'dart:math' as math;

import 'package:flutter/material.dart';

class LessonPopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color color; // warna kartu
  final Color textColor; // warna teks di kartu & tombol
  final double pointerDx; // geser segitiga agar menunjuk ke node
  final VoidCallback onStart;

  const LessonPopup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.color,
    required this.textColor,
    required this.onStart,
    this.pointerDx = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * -10),
            child: Transform.scale(
              scale: 0.94 + 0.06 * v,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // segitiga penunjuk ke node
          Transform.translate(
            offset: Offset(pointerDx, 6),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // kartu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withOpacity(0.75),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                _PopupButton(
                  label: buttonLabel,
                  textColor: textColor,
                  onTap: onStart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tombol putih 3D di dalam kartu
class _PopupButton extends StatefulWidget {
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _PopupButton({
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_PopupButton> createState() => _PopupButtonState();
}

class _PopupButtonState extends State<_PopupButton> {
  bool _pressed = false;
  DateTime? _pressStart;

  static const double height = 50;
  static const double depth = 5;

  // Tombol minimal tertahan sebesar ini supaya tap cepat tetap terlihat
  static const Duration minPress = Duration(milliseconds: 120);

  void _press() {
    _pressStart = DateTime.now();
    if (!_pressed) setState(() => _pressed = true);
  }

  Future<void> _release() async {
    final start = _pressStart;
    if (start != null) {
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minPress) {
        await Future.delayed(minPress - elapsed);
      }
    }
    if (mounted && _pressed) setState(() => _pressed = false);
  }

  Future<void> _handleTap() async {
    await _release();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // aktif seketika saat jari menyentuh layar
      onPointerDown: (_) => _press(),
      child: GestureDetector(
        onTapCancel: _release,
        onTap: _handleTap,
        child: SizedBox(
          height: height + depth,
          width: double.infinity,
          child: Stack(
            children: [
              // bibir bawah
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D6D6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              // permukaan
              AnimatedPositioned(
                duration: const Duration(milliseconds: 80),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                height: height,
                top: _pressed ? depth : 0,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
