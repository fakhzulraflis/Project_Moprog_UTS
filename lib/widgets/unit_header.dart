import 'package:flutter/material.dart';

class UnitHeader extends StatelessWidget {
  final Color color;
  final String sectionLabel; // contoh: 'BAGIAN 1, UNIT 1'
  final String title;
  final String guidebookAsset;
  final VoidCallback? onGuidebookTap;

  const UnitHeader({
    super.key,
    required this.color,
    required this.sectionLabel,
    required this.title,
    this.guidebookAsset =
        'assets/icons/guidebook.png', // <-- sesuaikan path asetmu
    this.onGuidebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ---- kiri: label + judul ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ---- kanan: tombol panduan ----
          _GuidebookButton(
            color: color,
            asset: guidebookAsset,
            onTap: onGuidebookTap,
          ),
        ],
      ),
    );
  }
}

// Tombol "PANDUAN" 3D dengan border
class _GuidebookButton extends StatefulWidget {
  final Color color;
  final String asset;
  final VoidCallback? onTap;

  const _GuidebookButton({
    required this.color,
    required this.asset,
    this.onTap,
  });

  @override
  State<_GuidebookButton> createState() => _GuidebookButtonState();
}

class _GuidebookButtonState extends State<_GuidebookButton> {
  bool _pressed = false;
  DateTime? _pressStart;

  static const double height = 46;
  static const double depth = 4;
  static const Duration minPress = Duration(milliseconds: 120);

  Color _darken(Color c, [double amount = 0.12]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

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
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final edge = _darken(widget.color);

    return Listener(
      onPointerDown: (_) => _press(),
      child: GestureDetector(
        onTapCancel: _release,
        onTap: _handleTap,
        child: Stack(
          children: [
            // bibir bawah (mengikuti ukuran Stack, mulai dari 'depth')
            Positioned.fill(
              top: depth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: edge,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            // permukaan: anak biasa, jadi penentu lebar Stack.
            // margin atas + bawah selalu = depth, jadi total tinggi tetap.
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              height: height,
              margin: EdgeInsets.only(
                top: _pressed ? depth : 0,
                bottom: _pressed ? 0 : depth,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: edge, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    widget.asset,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    // kalau path aset salah, tampil ikon cadangan (tidak crash)
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PANDUAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
