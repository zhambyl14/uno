import 'package:flutter/material.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../domain/game_state.dart';
import 'turn_ring.dart';

/// Compact opponent display: avatar, name, card count, turn highlight.
class OpponentSeat extends StatelessWidget {
  const OpponentSeat({
    super.key,
    required this.player,
    required this.isCurrent,
    this.turnEndsAt,
    this.turnSeconds,
  });

  final GamePlayer player;
  final bool isCurrent;

  /// Turn deadline/duration for the countdown ring; null when the mode has
  /// no timer (Family) — the ring then shows as a solid glow instead.
  final DateTime? turnEndsAt;
  final int? turnSeconds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: isCurrent ? 1.06 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(Insets.xs),
        decoration: BoxDecoration(
          color: isCurrent ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(Corners.m),
          border: Border.all(
            color: isCurrent ? scheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                TurnRing(
                  active: isCurrent,
                  endsAt: turnEndsAt,
                  totalSeconds: turnSeconds,
                  size: 54,
                  child: AvatarCircle(avatarId: player.avatarId, size: 46),
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: _CardCountBadge(count: player.hand.length),
                ),
                if (player.hand.length == 1)
                  const Positioned(top: -10, left: -6, child: _UnoFlag()),
              ],
            ),
            const SizedBox(height: Insets.xs),
            SizedBox(
              width: 64,
              child: Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCountBadge extends StatelessWidget {
  const _CardCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.s, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(Corners.l),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: scheme.onInverseSurface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _UnoFlag extends StatelessWidget {
  const _UnoFlag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(Corners.s),
      ),
      child: const Text(
        'UNO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 9,
        ),
      ),
    );
  }
}
