import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shows which way play is flowing around the table and does a full spin
/// whenever a Reverse card flips it — so the rotation is never a mystery.
class TurnDirectionIndicator extends StatefulWidget {
  const TurnDirectionIndicator({
    super.key,
    required this.direction,
    required this.color,
    this.size = 34,
  });

  /// 1 = clockwise, -1 = counter-clockwise (matches [GameState.direction]).
  final int direction;
  final Color color;
  final double size;

  @override
  State<TurnDirectionIndicator> createState() => _TurnDirectionIndicatorState();
}

class _TurnDirectionIndicatorState extends State<TurnDirectionIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );

  @override
  void didUpdateWidget(TurnDirectionIndicator old) {
    super.didUpdateWidget(old);
    if (old.direction != widget.direction) _spin.forward(from: 0);
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clockwise = widget.direction >= 0;
    return AnimatedBuilder(
      animation: _spin,
      builder: (_, child) {
        final t = Curves.easeOutBack.transform(_spin.value);
        return Transform.rotate(
          angle: t * (clockwise ? 1 : -1) * 2 * math.pi,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.16),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.55),
            width: 2,
          ),
        ),
        child: Icon(
          clockwise ? Icons.rotate_right_rounded : Icons.rotate_left_rounded,
          color: widget.color,
          size: widget.size * 0.62,
        ),
      ),
    );
  }
}
