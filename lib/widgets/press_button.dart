import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tombol 3D: permukaan turun menutupi "bibir" bawahnya saat disentuh.
// Pola yang sama dengan tombol di popup lesson pada Learn page.
class PressButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String? label;
  final IconData? icon;
  final Widget? child; // menggantikan label/icon kalau diisi
  final Color color; // warna permukaan
  final Color shadowColor; // warna bibir bawah
  final Color textColor;
  final Color? borderColor; // kalau diisi, tombol bergaya outline
  final double height;
  final double depth;
  final double radius;
  final double fontSize;
  final double? width; // null = selebar parent
  final EdgeInsetsGeometry padding;

  const PressButton({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.child,
    this.color = const Color(0xFF55B6E8),
    this.shadowColor = const Color(0xFF3895C5),
    this.textColor = Colors.white,
    this.borderColor,
    this.height = 50,
    this.depth = 5,
    this.radius = 14,
    this.fontSize = 17,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  // Biru utama aplikasi
  const PressButton.primary({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.child,
    this.height = 50,
    this.depth = 5,
    this.radius = 14,
    this.fontSize = 17,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : color = const Color(0xFF55B6E8),
       shadowColor = const Color(0xFF3895C5),
       textColor = Colors.white,
       borderColor = null;

  // Tombol gelap berbingkai (untuk aksi sekunder)
  const PressButton.outline({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.child,
    this.height = 50,
    this.depth = 5,
    this.radius = 14,
    this.fontSize = 17,
    this.width,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : color = const Color(0xFF272F33),
       shadowColor = const Color(0xFF38474C),
       borderColor = const Color(0xFF38474C);

  // Tombol merah (untuk aksi berbahaya)
  const PressButton.danger({
    super.key,
    this.onTap,
    this.label,
    this.icon,
    this.child,
    this.height = 50,
    this.depth = 5,
    this.radius = 14,
    this.fontSize = 17,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : color = const Color(0xFFFF4B4B),
       shadowColor = const Color(0xFFC93A3A),
       textColor = Colors.white,
       borderColor = null;

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  bool _pressed = false;
  DateTime? _pressStart;

  // Minimal tertahan supaya tap cepat tetap terlihat tertekan
  static const Duration _minPress = Duration(milliseconds: 120);

  bool get _enabled => widget.onTap != null;

  void _press() {
    if (!_enabled) return;
    _pressStart = DateTime.now();
    if (!_pressed) setState(() => _pressed = true);
  }

  Future<void> _release() async {
    final start = _pressStart;
    if (start != null) {
      final elapsed = DateTime.now().difference(start);
      if (elapsed < _minPress) {
        await Future.delayed(_minPress - elapsed);
      }
    }
    if (mounted && _pressed) setState(() => _pressed = false);
  }

  Future<void> _handleTap() async {
    await _release();
    widget.onTap?.call();
  }

  Widget _content(Color textColor) {
    if (widget.child != null) return widget.child!;
    final text = widget.label == null
        ? null
        : Text(
            widget.label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.baloo2(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: widget.fontSize,
              letterSpacing: 0.6,
            ),
          );
    final icon = widget.icon == null
        ? null
        : Icon(widget.icon, color: textColor, size: widget.fontSize + 5);
    if (text != null && icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Flexible(child: text),
        ],
      );
    }
    return text ?? icon ?? const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final surface = enabled ? widget.color : const Color(0xFF343C40);
    final lip = enabled ? widget.shadowColor : const Color(0xFF2B3236);
    final textColor = enabled ? widget.textColor : Colors.white38;
    final radius = BorderRadius.circular(widget.radius);

    return Listener(
      // aktif seketika saat jari menyentuh layar
      onPointerDown: (_) => _press(),
      child: GestureDetector(
        onTapCancel: _release,
        onTap: enabled ? _handleTap : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height + widget.depth,
          child: Stack(
            children: [
              // bibir bawah
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: widget.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: lip, borderRadius: radius),
                ),
              ),
              // permukaan
              AnimatedPositioned(
                duration: const Duration(milliseconds: 80),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                height: widget.height,
                top: _pressed ? widget.depth : 0,
                child: Container(
                  alignment: Alignment.center,
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: radius,
                    border: widget.borderColor == null
                        ? null
                        : Border.all(color: widget.borderColor!, width: 2),
                  ),
                  child: _content(textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
