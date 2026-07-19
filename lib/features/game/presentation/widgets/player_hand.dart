import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/insets.dart';
import '../../domain/game_state.dart';
import '../../domain/uno_card.dart';
import '../../domain/uno_rules.dart';
import 'uno_card_view.dart';

/// The local player's hand as a horizontal, mouse-draggable card strip.
/// Cards fan out slightly (a small rotation + arc lift growing away from
/// the center) for a hand-held-cards feel, and lift when playable.
class PlayerHand extends StatelessWidget {
  const PlayerHand({
    super.key,
    required this.state,
    required this.playerId,
    required this.myTurn,
    required this.onPlay,
  });

  final GameState state;
  final String playerId;
  final bool myTurn;
  final ValueChanged<UnoCard> onPlay;

  static const double _fanStep = 0.045;
  static const double _liftPerStep = 5;

  @override
  Widget build(BuildContext context) {
    final me = state.playerById(playerId) ?? state.players.first;
    final cards = me.hand;
    final cardWidth = context.isCompactHeight ? 56.0 : 68.0;
    final center = (cards.length - 1) / 2;

    return SizedBox(
      height: cardWidth * 1.45 + Insets.xl,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.m,
            vertical: Insets.m,
          ),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: Insets.xs),
          itemBuilder: (context, index) {
            final card = cards[index];
            final playable = myTurn && UnoRules.canPlayCard(state, card);
            final offsetFromCenter = index - center;
            final angle = offsetFromCenter * _fanStep;
            final lift = offsetFromCenter.abs() * _liftPerStep;
            return Semantics(
              button: playable,
              enabled: playable,
              label:
                  '${UnoCardView.symbolOf(card)} ${card.color.name}${playable ? ', playable' : ''}',
              child: Transform.translate(
                offset: Offset(0, lift - (playable ? 10 : 0)),
                child: Transform.rotate(
                  angle: angle,
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: playable ? () => onPlay(card) : null,
                    child: AnimatedScale(
                      scale: playable ? 1.06 : 1,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      child: UnoCardView(
                        card: card,
                        width: cardWidth,
                        playable: playable,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

extension on BuildContext {
  bool get isCompactHeight => MediaQuery.sizeOf(this).height < 680;
}
