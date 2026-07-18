import '../../../core/constants/strings.dart';

enum GameMode {
  classic(
    label: S.modeClassic,
    emoji: '🎴',
    handSize: 7,
    turnSeconds: 30,
    withSpecials: true,
    isTeam: false,
  ),
  family(
    label: S.modeFamily,
    emoji: '👨‍👩‍👧‍👦',
    handSize: 7,
    turnSeconds: null,
    withSpecials: false,
    isTeam: false,
  ),
  fast(
    label: S.modeFast,
    emoji: '⚡',
    handSize: 5,
    turnSeconds: 15,
    withSpecials: true,
    isTeam: false,
  ),
  team(
    label: S.modeTeam,
    emoji: '🤝',
    handSize: 7,
    turnSeconds: 30,
    withSpecials: true,
    isTeam: true,
  );

  const GameMode({
    required this.label,
    required this.emoji,
    required this.handSize,
    required this.turnSeconds,
    required this.withSpecials,
    required this.isTeam,
  });

  final String label;
  final String emoji;
  final int handSize;

  /// Null = no timer (Family mode has no time pressure for kids).
  final int? turnSeconds;
  final bool withSpecials;
  final bool isTeam;

  /// A getter (not a stored field) because it is localized and `S.locale`
  /// can change at runtime — enum instances themselves stay const.
  String get description => switch (this) {
    GameMode.classic => S.modeClassicDesc,
    GameMode.family => S.modeFamilyDesc,
    GameMode.fast => S.modeFastDesc,
    GameMode.team => S.modeTeamDesc,
  };
}
