import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';

enum GameMode {
  // Standard 108-card UNO deck (number/skip/reverse/draw-two/wild/wild-draw-
  // four) in every mode — no novelty cards. Only the pace/hand size/timer
  // differ between modes.
  classic(
    label: S.modeClassic,
    emoji: '🎴',
    handSize: 7,
    turnSeconds: 30,
    withSpecials: false,
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
    withSpecials: false,
    isTeam: false,
  ),
  team(
    label: S.modeTeam,
    emoji: '🤝',
    handSize: 7,
    turnSeconds: 30,
    withSpecials: false,
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

  /// Redesign v2: each mode gets its own saturated identity color instead of
  /// a flat neutral card, so the mode picker reads at a glance.
  List<Color> get gradientColors => switch (this) {
    GameMode.classic => const [Color(0xFF8B3FF0), Color(0xFFEC4899)],
    GameMode.family => const [Color(0xFF2DD4BF), Color(0xFF0F766E)],
    GameMode.fast => const [Color(0xFFFB923C), Color(0xFFC2410C)],
    GameMode.team => const [Color(0xFFEC4899), Color(0xFF9D174D)],
  };
}
