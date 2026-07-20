import 'dart:math';

import 'dart:ui' show Color;

enum Suit { spades, hearts, diamonds, clubs }

extension SuitX on Suit {
  String get symbol => switch (this) {
    Suit.spades => '♠',
    Suit.hearts => '♥',
    Suit.diamonds => '♦',
    Suit.clubs => '♣',
  };

  bool get isRed => this == Suit.hearts || this == Suit.diamonds;

  Color get color =>
      isRed ? const Color(0xFFE84C3D) : const Color(0xFF232336);
}

/// A standard playing card. [rank] is 1..13 (1=Ace, 11=J, 12=Q, 13=K).
/// In Crazy 8s a rank-8 card is wild.
class PlayingCard {
  const PlayingCard(this.suit, this.rank);
  final Suit suit;
  final int rank;

  bool get isWild => rank == 8;

  String get label => switch (rank) {
    1 => 'A',
    11 => 'J',
    12 => 'Q',
    13 => 'K',
    _ => '$rank',
  };

  static List<PlayingCard> shuffledDeck(Random rng) {
    final deck = [
      for (final suit in Suit.values)
        for (var rank = 1; rank <= 13; rank++) PlayingCard(suit, rank),
    ];
    deck.shuffle(rng);
    return deck;
  }
}
