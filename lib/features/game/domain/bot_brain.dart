import 'dart:math';

import 'game_action.dart';
import 'game_state.dart';
import 'uno_card.dart';
import 'uno_rules.dart';

/// Simple friendly AI for bot seats.
abstract final class BotBrain {
  static Duration thinkDelay(Random rng) =>
      Duration(milliseconds: 700 + rng.nextInt(900));

  static List<GameAction> decide(GameState s, String botId, Random rng) {
    final bot = s.playerById(botId);
    if (bot == null || s.currentPlayer.id != botId) return const [];
    final actions = <GameAction>[];

    // A drawn card must be resolved before the bot can end its turn. This
    // mirrors the same one-card-only rule used by the human UI.
    if (s.drawnCardId != null) {
      final drawn = bot.hand.where((c) => c.id == s.drawnCardId).firstOrNull;
      if (drawn != null && UnoRules.canPlayCard(s, drawn)) {
        return [
          PlayCardAction(
            botId,
            cardId: drawn.id,
            chosenColor: drawn.needsColorChoice
                ? _bestColor(bot.hand, drawn, rng)
                : null,
          ),
        ];
      }
      return [PassAction(botId)];
    }

    // Bots remember to say UNO most of the time — but not always.
    if (bot.hand.length == 2 && !bot.saidUno && rng.nextDouble() < 0.85) {
      actions.add(SayUnoAction(botId));
    }

    final playable = [
      for (final card in bot.hand)
        if (UnoRules.canPlayCard(s, card)) card,
    ];
    if (playable.isEmpty) {
      actions.add(DrawCardAction(botId));
      return actions;
    }

    playable.shuffle(rng);
    playable.sort((a, b) => _score(b).compareTo(_score(a)));
    final card = playable.first;
    actions.add(
      PlayCardAction(
        botId,
        cardId: card.id,
        chosenColor: card.needsColorChoice
            ? _bestColor(bot.hand, card, rng)
            : null,
      ),
    );
    return actions;
  }

  /// Prefer dumping colored cards; hold wilds (especially Wild +4) for later.
  static int _score(UnoCard card) => switch (card.type) {
    CardType.number => 4,
    CardType.skip ||
    CardType.reverse ||
    CardType.drawTwo ||
    CardType.star ||
    CardType.gift => 3,
    CardType.rainbow || CardType.shuffle => 2,
    CardType.wild => 1,
    CardType.wildFour => 0,
  };

  static CardColor _bestColor(List<UnoCard> hand, UnoCard played, Random rng) {
    final counts = <CardColor, int>{};
    for (final card in hand) {
      if (card.id == played.id || card.color == CardColor.wild) continue;
      counts[card.color] = (counts[card.color] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      const colors = [
        CardColor.red,
        CardColor.yellow,
        CardColor.green,
        CardColor.blue,
      ];
      return colors[rng.nextInt(colors.length)];
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
