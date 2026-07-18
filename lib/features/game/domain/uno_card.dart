enum CardColor { red, yellow, green, blue, wild }

/// Child-safe deck: classic actions plus friendly specials.
/// No bomb/poison/curse-style aggressive cards by design.
enum CardType {
  number,
  skip,
  reverse,
  drawTwo,
  wild,
  wildFour,
  star, // extra turn
  gift, // pass one card to the next player
  shuffle, // shuffle all hands and re-deal (official "Shuffle Hands" rule)
  rainbow, // for one turn the table accepts any color
}

class UnoCard {
  const UnoCard({
    required this.id,
    required this.color,
    required this.type,
    this.number = -1,
  });

  final String id;
  final CardColor color;
  final CardType type;

  /// 0..9 for number cards, -1 otherwise.
  final int number;

  bool get isWildType =>
      type == CardType.wild ||
      type == CardType.wildFour ||
      type == CardType.shuffle ||
      type == CardType.rainbow;

  /// True when a wild-type card requires the player to pick a color.
  bool get needsColorChoice =>
      type == CardType.wild ||
      type == CardType.wildFour ||
      type == CardType.shuffle;

  /// Whether this card can be played on the current table.
  bool matches({
    required CardColor activeColor,
    required UnoCard top,
    required bool rainbowFree,
  }) {
    if (isWildType) return true;
    if (rainbowFree) return true;
    if (color == activeColor) return true;
    if (type == CardType.number) {
      return top.type == CardType.number && number == top.number;
    }
    return type == top.type;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'c': color.index,
    't': type.index,
    'n': number,
  };

  factory UnoCard.fromJson(Map<String, dynamic> json) => UnoCard(
    id: json['id'] as String,
    color: CardColor.values[json['c'] as int],
    type: CardType.values[json['t'] as int],
    number: json['n'] as int,
  );

  @override
  bool operator ==(Object other) => other is UnoCard && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
