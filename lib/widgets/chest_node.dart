import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_image.dart';

enum ChestState { locked, ready, opened }

const Color _bubbleBg = Color(0xFF131F24);
const Color _bubbleBorder = Color(0xFF37464F);
const Color _plateColor = Color(0xFF2B373E);
const Color _openGreen = Color(0xFF58CC02);

class ChestNode extends StatefulWidget {
  final ChestState state;

  /// Dipanggil saat peti ditekan (hanya jika state == ready).
  /// Parameter = titik tengah peti di koordinat layar.
  final void Function(Offset globalCenter)? onOpen;

  // ===== UKURAN PETI =====
  // 1.0 = ukuran awal, makin besar angkanya makin besar petinya
  static const double scale = 1.25;

  // ===== SESUAIKAN PATH ASET =====
  static const String lockedAsset = 'assets/path/unreachchest.png';
  static const String closedAsset = 'assets/path/unopenedchest.svg';
  static const String openAsset = 'assets/path/chestopen.png';

  const ChestNode({super.key, required this.state, this.onOpen});

  @override
  State<ChestNode> createState() => _ChestNodeState();
}

class _ChestNodeState extends State<ChestNode>
    with SingleTickerProviderStateMixin {
  static const double s = ChestNode.scale;

  final GlobalKey _chestKey = GlobalKey();

  bool _pressed = false;
  DateTime? _pressStart;
  static const Duration minPress = Duration(milliseconds: 120);

  // efek memantul saat peti terbuka
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _bounceScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.18,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.18,
        end: 0.96,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.96,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
  ]).animate(_bounce);

  @override
  void didUpdateWidget(covariant ChestNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == ChestState.ready &&
        widget.state == ChestState.opened) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
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
    if (!mounted) return;

    final box = _chestKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final center = box.localToGlobal(box.size.center(Offset.zero));
    widget.onOpen?.call(center);
  }

  Widget _chestImage() {
    String asset = ChestNode.lockedAsset;
    IconData icon = Icons.inventory_2_rounded;
    Color iconColor = const Color(0xFF52656D);

    if (widget.state == ChestState.ready) {
      asset = ChestNode.closedAsset;
      iconColor = const Color(0xFFFFC800);
    } else if (widget.state == ChestState.opened) {
      asset = ChestNode.openAsset;
      icon = Icons.inventory_2_outlined;
      iconColor = const Color(0xFFFFC800);
    }

    return SizedBox(
      key: ValueKey(widget.state),
      width: 92 * s,
      height: 84 * s,
      child: AppImage(
        asset,
        fit: BoxFit.contain,
        // dipakai untuk PNG; SVG tidak punya ikon cadangan
        errorBuilder: (_, __, ___) =>
            Icon(icon, size: 60 * s, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.state == ChestState.ready;

    final chest = Listener(
      onPointerDown: ready ? (_) => _press() : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapCancel: ready ? _release : null,
        onTap: ready ? _handleTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 80),
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: _bounceScale,
            builder: (context, child) => Transform.scale(
              scale: _bounceScale.value,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
            child: SizedBox(
              key: _chestKey,
              width: 104 * s,
              height: 96 * s,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // plat gelap di belakang peti
                  Container(
                    width: 100 * s,
                    height: 66 * s,
                    decoration: BoxDecoration(
                      color: _plateColor,
                      borderRadius: BorderRadius.circular(14 * s),
                    ),
                  ),
                  // peti
                  Padding(
                    padding: EdgeInsets.only(bottom: 8 * s),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _chestImage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Dasar peti selalu menempel di dasar slot (sama seperti node pelajaran)
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ready) ...[_OpenBubble(width: 96 * s), const SizedBox(height: 4)],
          chest,
        ],
      ),
    );
  }
}

// =====================================================
// BUBBLE "BUKA" (naik turun)
// =====================================================
class _OpenBubble extends StatefulWidget {
  final double width;

  const _OpenBubble({required this.width});

  @override
  State<_OpenBubble> createState() => _OpenBubbleState();
}

class _OpenBubbleState extends State<_OpenBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _bob = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const border = BorderSide(color: _bubbleBorder, width: 2);

    return AnimatedBuilder(
      animation: _bob,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -8 * _bob.value),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.width,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _bubbleBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.fromBorderSide(border),
            ),
            child: const Text(
              'BUKA',
              style: TextStyle(
                color: _openGreen,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -6),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: _bubbleBg,
                  border: Border(right: border, bottom: border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
