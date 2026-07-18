import 'dart:ui';

import '../../../core/constants/catalog.dart';
import '../../../core/constants/strings.dart';

enum ShopCategory { avatars, cardSkins, tableThemes }

class ShopItem {
  const ShopItem({
    required this.id,
    required this.price,
    required this.category,
    required this.previewA,
    required this.previewB,
    this.emoji,
  });

  final String id;
  final int price;
  final ShopCategory category;
  final Color previewA;
  final Color previewB;
  final String? emoji;

  bool get isEquippable => category != ShopCategory.avatars;

  /// A getter (not a stored field): it is localized and `S.locale` can
  /// change at runtime, while `ShopItem` instances stay const.
  String get name => switch (id) {
    'pack_jungle' => S.itemJungle,
    'pack_sea' => S.itemSea,
    'pack_sweets' => S.itemSweets,
    'skin_night' => S.itemNight,
    'skin_candy' => S.itemCandy,
    'theme_blue' => S.itemBlueTable,
    'theme_purple' => S.itemPurpleTable,
    'theme_sunset' => S.itemSunset,
    _ => id,
  };
}

/// Card back / face-accent skins. `skin_classic` is owned by everyone.
class CardSkin {
  const CardSkin(this.id, this.back);
  final String id;
  final Color back;

  static const Map<String, CardSkin> all = {
    'skin_classic': CardSkin('skin_classic', Color(0xFF3B3B54)),
    'skin_night': CardSkin('skin_night', Color(0xFF10203A)),
    'skin_candy': CardSkin('skin_candy', Color(0xFFB0356B)),
  };

  static CardSkin byId(String id) => all[id] ?? all['skin_classic']!;
}

/// Game table background themes. `theme_green` is the default.
class TableTheme {
  const TableTheme(this.id, this.top, this.bottom);
  final String id;
  final Color top;
  final Color bottom;

  static const Map<String, TableTheme> all = {
    'theme_green': TableTheme(
      'theme_green',
      Color(0xFF1E5631),
      Color(0xFF2E7D32),
    ),
    'theme_blue': TableTheme(
      'theme_blue',
      Color(0xFF17324F),
      Color(0xFF25507D),
    ),
    'theme_purple': TableTheme(
      'theme_purple',
      Color(0xFF2A1E4F),
      Color(0xFF4A2E7D),
    ),
    'theme_sunset': TableTheme(
      'theme_sunset',
      Color(0xFF7D3A2E),
      Color(0xFFB5632E),
    ),
  };

  static TableTheme byId(String id) => all[id] ?? all['theme_green']!;
}

abstract final class Shop {
  static const List<ShopItem> items = [
    // Avatar packs (unlock preset avatars — never custom uploads).
    ShopItem(
      id: 'pack_jungle',
      price: 120,
      category: ShopCategory.avatars,
      previewA: Color(0xFFFFE082),
      previewB: Color(0xFFDCEDC8),
      emoji: '🦁',
    ),
    ShopItem(
      id: 'pack_sea',
      price: 120,
      category: ShopCategory.avatars,
      previewA: Color(0xFFB2EBF2),
      previewB: Color(0xFFBBDEFB),
      emoji: '🐬',
    ),
    ShopItem(
      id: 'pack_sweets',
      price: 150,
      category: ShopCategory.avatars,
      previewA: Color(0xFFF8BBD0),
      previewB: Color(0xFFE1BEE7),
      emoji: '🍩',
    ),
    // Card skins.
    ShopItem(
      id: 'skin_night',
      price: 120,
      category: ShopCategory.cardSkins,
      previewA: Color(0xFF10203A),
      previewB: Color(0xFF25507D),
      emoji: '🌙',
    ),
    ShopItem(
      id: 'skin_candy',
      price: 150,
      category: ShopCategory.cardSkins,
      previewA: Color(0xFFB0356B),
      previewB: Color(0xFFF8BBD0),
      emoji: '🍬',
    ),
    // Table themes.
    ShopItem(
      id: 'theme_blue',
      price: 100,
      category: ShopCategory.tableThemes,
      previewA: Color(0xFF17324F),
      previewB: Color(0xFF25507D),
      emoji: '🔵',
    ),
    ShopItem(
      id: 'theme_purple',
      price: 120,
      category: ShopCategory.tableThemes,
      previewA: Color(0xFF2A1E4F),
      previewB: Color(0xFF4A2E7D),
      emoji: '🟣',
    ),
    ShopItem(
      id: 'theme_sunset',
      price: 150,
      category: ShopCategory.tableThemes,
      previewA: Color(0xFF7D3A2E),
      previewB: Color(0xFFB5632E),
      emoji: '🌅',
    ),
  ];

  static List<ShopItem> byCategory(ShopCategory category) => [
    for (final item in items)
      if (item.category == category) item,
  ];

  static String categoryLabel(ShopCategory category) => switch (category) {
    ShopCategory.avatars => S.catAvatars,
    ShopCategory.cardSkins => S.catCardSkins,
    ShopCategory.tableThemes => S.catTableThemes,
  };

  /// How many avatars a pack unlocks (for the shop card subtitle).
  static int avatarsInPack(String packId) => Avatars.packs[packId]?.length ?? 0;
}
