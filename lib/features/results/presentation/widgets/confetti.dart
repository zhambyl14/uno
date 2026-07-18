import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/game_palette.dart';

/// Lightweight one-shot confetti (no packages, no assets). Runs once then
/// idles; the controller is disposed with the widget.
class Confetti extends StatefulWidget {
  const Confetti({super.key, this.pieces = 80});
  final int pieces;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _confetti;

  static const _colors = [
    GamePalette.red,
    GamePalette.yellow,
    GamePalette.green,
    GamePalette.blue,
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _confetti = List.generate(
      widget.pieces,
      (_) => _Piece(
        x: rng.nextDouble(),
        delay: rng.nextDouble() * 0.3,
        speed: 0.7 + rng.nextDouble() * 0.6,
        drift: (rng.nextDouble() - 0.5) * 0.3,
        color: _colors[rng.nextInt(_colors.length)],
        size: 6 + rng.nextDouble() * 6,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_confetti, _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.color,
    required this.size,
  });
  final double x;
  final double delay;
  final double speed;
  final double drift;
  final Color color;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);
  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final progress = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (progress <= 0) continue;
      final dy = progress * p.speed * size.height;
      final dx = (p.x + p.drift * progress) * size.width;
      paint.color = p.color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(dx, dy - size.height * 0.1),
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
