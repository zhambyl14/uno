import 'package:flutter/services.dart';

import '../../features/game/domain/game_state.dart';

/// Tactile feedback for game moments. Built-in only — no audio assets or
/// extra dependencies — so it stays tiny and works everywhere (a no-op on
/// web/desktop). Fire only for events the local player is part of, otherwise
/// bot turns would buzz the phone constantly.
abstract final class GameHaptics {
  static void forEvent(GameEventType type) {
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
