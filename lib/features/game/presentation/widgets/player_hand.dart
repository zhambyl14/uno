import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/insets.dart';
import '../../domain/game_state.dart';
import '../../domain/uno_card.dart';
import 'uno_card_view.dart';

/// The local player's hand as a horizontal, mouse-draggable card strip.
class PlayerHand extends StatelessWidget {
  const PlayerHand({
    super.key,
    required this.state,
    required this.myTurn,
    required this.onPlay,
  });

  final GameState state;
  final bool myTurn;
  final ValueChanged<UnoCard> onPlay;

  @override
  Widget build(BuildContext context) {
    final me = state.players.firstWhere(
      (p) => !p.isBot,
      orElse: () => state.players.first,
    );
    final cards = me.hand;
    final cardWidth = context.isCompactHeight ? 56.0 : 68.0;

    return SizedBox(
      height: cardWidth * 1.45 + Insets.m,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Insets.m),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: Insets.xs),
          itemBuilder: (context, index) {
            final card = cards[index];
            final playable =
                myTurn &&
                card.matches(
                  activeColor: state.activeColor,
                  top: state.topCard,
                  rainbowFree: state.rainbowFree,
                );
            return Center(
              child: GestureDetector(
                onTap: playable ? () => onPlay(card) : null,
                child: AnimatedScale(
                  scale: playable ? 1.05 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: UnoCardView(
                    card: card,
                    width: cardWidth,
                    playable: playable,
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
