import 'dart:math';

import 'uno_card.dart';

/// Builds a shuffled deck. Standard: 108 cards. With specials: +16
/// (per color: 1 Star + 1 Gift; plus 4 Shuffle + 4 Rainbow).
abstract final class Deck {
  static List<UnoCard> build({
    required bool withSpecials,
    required Random rng,
  }) {
    final cards = <UnoCard>[];
    var nextId = 0;
    UnoCard make(CardColor color, CardType type, [int number = -1]) =>
        UnoCard(id: 'c${nextId++}', color: color, type: type, number: number);

    const colors = [
      CardColor.red,
      CardColor.yellow,
      CardColor.green,
      CardColor.blue,
    ];
    for (final color in colors) {
      cards.add(make(color, CardType.number, 0));
      for (var n = 1; n <= 9; n++) {
        cards
          ..add(make(color, CardType.number, n))
          ..add(make(color, CardType.number, n));
      }
      for (var i = 0; i < 2; i++) {
        cards
          ..add(make(color, CardType.skip))
          ..add(make(color, CardType.reverse))
          ..add(make(color, CardType.drawTwo));
      }
      if (withSpecials) {
        cards
          ..add(make(color, CardType.star))
          ..add(make(color, CardType.gift));
      }
    }
    for (var i = 0; i < 4; i++) {
      cards
        ..add(make(CardColor.wild, CardType.wild))
        ..add(make(CardColor.wild, CardType.wildFour));
      if (withSpecials) {
        cards
          ..add(make(CardColor.wild, CardType.shuffle))
          ..add(make(CardColor.wild, CardType.rainbow));
      }
    }
    cards.shuffle(rng);
    return cards;
  }
}
