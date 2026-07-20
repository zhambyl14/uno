import 'dart:ui';

/// Semantic card colors — fixed game identity, independent of app theme.
abstract final class GamePalette {
  static const Color red = Color(0xFFE84C3D);
  static const Color yellow = Color(0xFFF7C948);
  static const Color green = Color(0xFF2EA95C);
  static const Color blue = Color(0xFF2D7DD2);
  static const Color wild = Color(0xFF3B3B54);
  static const Color cardFace = Color(0xFFFFFFFF);
  static const Color cardInk = Color(0xFF232336);

  /// Redesign v2 brand gradient (purple → magenta → pink) — the app's hero
  /// accent, used on the main Play card, current-turn ring and victory
  /// moments. Distinct from the fixed card-suit colors above.
  static const List<Color> brandGradient = [
    Color(0xFF8B3FF0),
    Color(0xFFC026D3),
    Color(0xFFEC4899),
  ];

  static const Color brandStart = Color(0xFF8B3FF0);
  static const Color brandEnd = Color(0xFFEC4899);
}
