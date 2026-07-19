import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/game_palette.dart';
import '../../../../core/constants/insets.dart';
import '../../domain/game_state.dart';

/// A compact announcement that makes important game events feel immediate
/// without covering the cards or blocking interaction.
class GameEventBanner extends StatelessWidget {
  const GameEventBanner({
    super.key,
    required this.message,
    required this.event,
    required this.isMyTurn,
  });

  final String message;
  final GameEvent? event;
  final bool isMyTurn;

  @override
  Widget build(BuildContext context) {
    final style = _eventStyle(event, Theme.of(context).colorScheme, isMyTurn);
    final key = '${event?.type}:${event?.actorId}:${event?.targetId}:$message';
    return SizedBox(
      height: 42,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, -0.18),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
        child: Container(
          key: ValueKey(key),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.m,
            vertical: Insets.xs,
          ),
          decoration: BoxDecoration(
            color: style.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(Corners.l),
            border: Border.all(color: style.color.withValues(alpha: 0.42)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(style.icon, size: 18, color: style.color),
              const SizedBox(width: Insets.xs),
              Flexible(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: style.color,
                    fontWeight: FontWeight.w800,
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

/// A short, non-interactive sparkle burst for action cards and UNO moments.
class GameEventBurst extends StatefulWidget {
  const GameEventBurst({super.key, required this.event, required this.trigger});

  final GameEvent? event;
  final String trigger;

  @override
  State<GameEventBurst> createState() => _GameEventBurstState();
}

class _GameEventBurstState extends State<GameEventBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 720),
  )..forward();

  @override
  void didUpdateWidget(GameEventBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) return const SizedBox.expand();
    final color = _eventStyle(
      widget.event,
      Theme.of(context).colorScheme,
      false,
    ).color;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          painter: _BurstPainter(progress: _controller.value, color: color),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final center = Offset(size.width / 2, size.height * 0.48);
    final eased = Curves.easeOutCubic.transform(progress);
    final radius = size.shortestSide * (0.06 + 0.27 * eased);
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withValues(alpha: alpha * 0.8);

    for (var i = 0; i < 14; i++) {
      final angle = (math.pi * 2 * i / 14) - math.pi / 2;
      final wave = 0.72 + (i % 3) * 0.12;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * wave;
      final particleRadius = 2.5 + (i % 3) * 1.2;
      canvas.drawCircle(point, particleRadius * (1 - progress * 0.35), paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

({IconData icon, Color color}) _eventStyle(
  GameEvent? event,
  ColorScheme scheme,
  bool isMyTurn,
) => switch (event?.type) {
  GameEventType.drewTwo ||
  GameEventType.drewFour ||
  GameEventType.unoPenalty => (icon: Icons.bolt_rounded, color: scheme.error),
  GameEventType.skip => (icon: Icons.block_rounded, color: GamePalette.red),
  GameEventType.reverse || GameEventType.shuffleHands => (
    icon: Icons.sync_rounded,
    color: GamePalette.blue,
  ),
  GameEventType.rainbow => (
    icon: Icons.palette_rounded,
    color: GamePalette.yellow,
  ),
  GameEventType.saidUno => (
    icon: Icons.local_fire_department_rounded,
    color: Colors.deepOrange,
  ),
  GameEventType.extraTurn => (
    icon: Icons.stars_rounded,
    color: GamePalette.yellow,
  ),
  GameEventType.gift => (icon: Icons.redeem_rounded, color: Colors.pinkAccent),
  GameEventType.win => (
    icon: Icons.emoji_events_rounded,
    color: GamePalette.yellow,
  ),
  _ => (
    icon: isMyTurn ? Icons.touch_app_rounded : Icons.hourglass_top_rounded,
    color: isMyTurn ? scheme.primary : scheme.onSurfaceVariant,
  ),
};
