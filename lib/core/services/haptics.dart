import 'package:flutter/services.dart';

import '../../features/game/domain/game_state.dart';

/// Tactile feedback for game moments. Built-in only — no audio assets or
/// extra dependencies — so it stays tiny and works everywhere (a no-op on
/// web/desktop). Respects the "Sound & vibration" setting via [enabled].
abstract final class GameHaptics {
  /// Mirrors the Settings toggle; kept in sync by the app root.
  static bool enabled = true;

  static void tap() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void success() {
    if (enabled) HapticFeedback.heavyImpact();
  }

  /// Fires the pulse that best matches a UNO game event. Only call for events
  /// the local player is part of, else bot turns would buzz nonstop.
  static void forEvent(GameEventType type) {
    if (!enabled) return;
    switch (type) {
      case GameEventType.saidUno:
      case GameEventType.win:
        HapticFeedback.heavyImpact();
      case GameEventType.drewTwo:
      case GameEventType.drewFour:
      case GameEventType.unoPenalty:
      case GameEventType.shuffleHands:
        HapticFeedback.mediumImpact();
      case GameEventType.skip:
      case GameEventType.reverse:
      case GameEventType.extraTurn:
      case GameEventType.rainbow:
      case GameEventType.gift:
        HapticFeedback.lightImpact();
      case GameEventType.played:
      case GameEventType.drewCard:
      case GameEventType.timeoutDraw:
      case GameEventType.passed:
        HapticFeedback.selectionClick();
    }
  }
}
