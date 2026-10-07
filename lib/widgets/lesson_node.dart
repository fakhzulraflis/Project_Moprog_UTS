import 'dart:math' as math;

import 'package:flutter/material.dart';

enum NodeState { locked, current, completed }

enum NodeType { star, check, trophy }

const Color _bubbleBg = Color(0xFF131F24);
const Color _ringColor = Color(0xFF37464F);

class LessonNode extends StatefulWidget {
  final NodeState state;
  final NodeType type;
  final Color color; // warna tombol saat tidak locked
  final VoidCallback? onTap;
  final bool showStartBubble;

  const LessonNode({
    super.key,
    required this.state,
    required this.type,
    required this.color,
    this.onTap,
    this.showStartBubble = true,
  });

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode> {
  bool _pressed = false;
  DateTime? _pressStart;

  static const double w = 88;
  static const double h = 76;
  static const double depth = 8; // tebal "bibir" 3D

  // Tombol minimal tertahan sebesar ini supaya tap cepat tetap terlihat
  static const Duration minPress = Duration(milliseconds: 120);

  static const Color lockedFace = Color(0xFF37464F);
  static const Color lockedLip = Color(0xFF2B373E);

  Color _darken(Color c, [double amount = 0.15]) {
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
    final locked = widget.state == NodeState.locked;
    final current = widget.state == NodeState.current;

    // Efek mengkilap hanya untuk node yang sudah selesai.
    final shiny = widget.state == NodeState.completed;

    final face = locked ? lockedFace : widget.color;
    final lip = locked ? lockedLip : _darken(face);
    final shape = BorderRadius.all(Radius.elliptical(w, h));

    final button = Listener(
      // aktif seketika saat jari menyentuh layar
      onPointerDown: locked ? null : (_) => _press(),
      child: GestureDetector(
        onTapCancel: locked ? null : _release,
        onTap: locked ? null : _handleTap,
        child: SizedBox(
          width: w,
          height: h + depth,
          child: Stack(
            children: [
              // bibir gelap (bagian bawah 3D)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: h,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: lip, borderRadius: shape),
                ),
              ),
              // permukaan tombol (turun saat ditekan)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 80),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                height: h,
                top: _pressed ? depth : 0,
                child: Container(
                  decoration: BoxDecoration(color: face, borderRadius: shape),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // lapisan mengkilap
                      if (shiny)
                        IgnorePointer(
                          child: ClipRRect(
                            borderRadius: shape,
                            child: CustomPaint(painter: _ShinePainter()),
                          ),
                        ),
                      // ikon
                      Center(child: _buildIcon(locked)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Footprint disamakan dengan node aktif (ring 6 + padding 8 = 14),
    // supaya posisi tombol konsisten di semua status
    if (!current) {
      return Padding(padding: const EdgeInsets.all(14), child: button);
    }

    // Node aktif: bubble MULAI + ring
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: widget.showStartBubble,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: _StartBubble(color: widget.color),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: _ringColor, width: 6),
          ),
          child: button,
        ),
      ],
    );
  }

  Widget _buildIcon(bool locked) {
    if (locked) {
      if (widget.type == NodeType.trophy) {
        return Image.asset(
          'assets/path/unreachpath4.png',
          width: 44,
          height: 44,
        );
      }

      return Image.asset('assets/path/unreachpath.png', width: 40, height: 40);
    }

    switch (widget.type) {
      case NodeType.star:
        return Image.asset('assets/path/undonepath.png', width: 40, height: 40);

      case NodeType.check:
        return Image.asset('assets/path/donepath2.png', width: 40, height: 40);

      case NodeType.trophy:
        return Image.asset(
          'assets/path/reachedpath4.png',
          width: 44,
          height: 44,
        );
    }
  }
}

class _ShinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.20),
            Colors.white.withOpacity(0.0),
            Colors.black.withOpacity(0.10),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    final bandRect = Rect.fromLTWH(w * 0.22, 0, w * 0.56, h);
    final bandPath = Path()
      ..moveTo(w * 0.52, 0)
      ..lineTo(w * 0.78, 0)
      ..lineTo(w * 0.48, h)
      ..lineTo(w * 0.22, h)
      ..close();

    canvas.drawPath(
      bandPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(bandRect),
    );

    canvas.save();
    final glossRect = Rect.fromLTWH(w * 0.12, h * 0.07, w * 0.56, h * 0.36);
    canvas.translate(glossRect.center.dx, glossRect.center.dy);
    canvas.rotate(-0.30);
    canvas.translate(-glossRect.center.dx, -glossRect.center.dy);
    canvas.drawOval(
      glossRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.42),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(glossRect),
    );
    canvas.restore();

    final rimRect = Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.90, h * 0.90);
    canvas.drawArc(
      rimRect,
      math.pi * 1.08,
      math.pi * 0.84,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );

    canvas.drawArc(
      rimRect,
      math.pi * 0.14,
      math.pi * 0.72,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StartBubble extends StatefulWidget {
  final Color color;

  const _StartBubble({required this.color});

  @override
  State<_StartBubble> createState() => _StartBubbleState();
}

class _StartBubbleState extends State<_StartBubble>
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
    const border = BorderSide(color: _ringColor, width: 2);

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
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _bubbleBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.fromBorderSide(border),
            ),
            child: Text(
              'MULAI',
              style: TextStyle(
                color: widget.color,
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
