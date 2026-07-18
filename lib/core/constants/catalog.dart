import 'dart:ui';

/// Preset avatars — players can NEVER upload their own image (child safety).
class AvatarDef {
  const AvatarDef(this.id, this.emoji, this.background);
  final String id;
  final String emoji;
  final Color background;
}

abstract final class Avatars {
  static const List<AvatarDef> free = [
    AvatarDef('cat', '🐱', Color(0xFFFFE0B2)),
    AvatarDef('dog', '🐶', Color(0xFFD7CCC8)),
    AvatarDef('fox', '🦊', Color(0xFFFFCCBC)),
    AvatarDef('panda', '🐼', Color(0xFFE0E0E0)),
    AvatarDef('penguin', '🐧', Color(0xFFB3E5FC)),
    AvatarDef('rocket', '🚀', Color(0xFFD1C4E9)),
    AvatarDef('star', '⭐', Color(0xFFFFF9C4)),
    AvatarDef('rainbow', '🌈', Color(0xFFC8E6C9)),
  ];

  /// Unlockable via shop avatar packs (pack id -> avatars).
  static const Map<String, List<AvatarDef>> packs = {
    'pack_jungle': [
      AvatarDef('lion', '🦁', Color(0xFFFFE082)),
      AvatarDef('tiger', '🐯', Color(0xFFFFCC80)),
      AvatarDef('koala', '🐨', Color(0xFFCFD8DC)),
      AvatarDef('frog', '🐸', Color(0xFFDCEDC8)),
    ],
    'pack_sea': [
      AvatarDef('dolphin', '🐬', Color(0xFFB2EBF2)),
      AvatarDef('whale', '🐳', Color(0xFFBBDEFB)),
      AvatarDef('fish', '🐠', Color(0xFFB2DFDB)),
      AvatarDef('crab', '🦀', Color(0xFFFFCDD2)),
    ],
    'pack_sweets': [
      AvatarDef('donut', '🍩', Color(0xFFF8BBD0)),
      AvatarDef('cupcake', '🧁', Color(0xFFE1BEE7)),
      AvatarDef('lollipop', '🍭', Color(0xFFFFE0F0)),
      AvatarDef('strawberry', '🍓', Color(0xFFFFCDD2)),
    ],
  };

  static AvatarDef byId(String id) {
    for (final a in free) {
      if (a.id == id) return a;
    }
    for (final pack in packs.values) {
      for (final a in pack) {
        if (a.id == id) return a;
      }
    }
    return free.first;
  }

  /// Avatars available to a player owning the given shop item ids.
  static List<AvatarDef> unlockedFor(Set<String> ownedItems) => [
    ...free,
    for (final entry in packs.entries)
      if (ownedItems.contains(entry.key)) ...entry.value,
  ];
}

/// Safe reaction emojis — fixed list, nothing aggressive or adult.
abstract final class SafeEmojis {
  static const List<String> base = [
    '😀',
    '😄',
    '😅',
    '🙂',
    '👍',
    '👏',
    '🎉',
    '❤️',
    '⭐',
    '🌈',
  ];
  static const List<String> partyPack = ['🥳', '🤩', '😎', '🦄', '🍀', '🎈'];

  static List<String> unlockedFor(Set<String> ownedItems) => [
    ...base,
    if (ownedItems.contains('pack_party_emoji')) ...partyPack,
  ];
}

/// Friendly bot names (clearly marked as bots in the UI).
abstract final class BotNames {
  static const List<String> all = [
    'Айсұлу',
    'Данияр',
    'Мерей',
    'Аружан',
    'Санжар',
    'Инжу',
    'Алдияр',
  ];
}
