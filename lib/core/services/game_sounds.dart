import 'package:audioplayers/audioplayers.dart';

import '../../features/game/domain/game_state.dart';

enum Sfx { tap, cardPlay, draw, special, penalty, uno, buzz, snap, match, win }

extension on Sfx {
  String get asset => switch (this) {
    Sfx.tap => 'sfx/tap.wav',
    Sfx.cardPlay => 'sfx/card_play.wav',
    Sfx.draw => 'sfx/draw.wav',
    Sfx.special => 'sfx/special.wav',
    Sfx.penalty => 'sfx/penalty.wav',
    Sfx.uno => 'sfx/uno.wav',
    Sfx.buzz => 'sfx/buzz.wav',
    Sfx.snap => 'sfx/snap.wav',
    Sfx.match => 'sfx/match.wav',
    Sfx.win => 'sfx/win.wav',
  };
}

/// Short, synthesized sound effects (no licensed samples — original
/// procedural tones, see tool/gen_sfx.py). Respects the "Sound & vibration"
/// setting via [enabled]. Every play is wrapped in try/catch: a missing audio
/// backend (headless tests, an unsupported platform) must never crash a
/// game action — sound is a nice-to-have, not a dependency.
abstract final class GameSounds {
  static bool enabled = true;

  /// Low-latency pool: AudioPlayer.play() on a dedicated low-latency player
  /// interrupts its own previous sound, so short overlapping UI sounds
  /// (rapid taps) don't queue up and lag behind the action.
  static final AudioPlayer _player = AudioPlayer()
    ..setPlayerMode(PlayerMode.lowLatency);

  static Future<void> play(Sfx sfx) async {
    if (!enabled) return;
    try {
      await _player.play(AssetSource(sfx.asset), volume: 0.7);
    } catch (_) {
      // No-op: platform without audio support, or asset not bundled in tests.
    }
  }

  /// Fires the sound that best matches a UNO game event. Only call for
  /// events the local player is part of (mirrors [GameHaptics.forEvent]),
  /// else every bot turn would make noise.
  static void forEvent(GameEventType type) {
    switch (type) {
      case GameEventType.saidUno:
        play(Sfx.uno);
      case GameEventType.win:
        play(Sfx.win);
      case GameEventType.drewTwo:
      case GameEventType.drewFour:
      case GameEventType.unoPenalty:
        play(Sfx.penalty);
      case GameEventType.shuffleHands:
        play(Sfx.special);
      case GameEventType.skip:
      case GameEventType.reverse:
      case GameEventType.extraTurn:
      case GameEventType.rainbow:
      case GameEventType.gift:
        play(Sfx.special);
      case GameEventType.played:
        play(Sfx.cardPlay);
      case GameEventType.drewCard:
      case GameEventType.timeoutDraw:
        play(Sfx.draw);
      case GameEventType.passed:
        play(Sfx.tap);
    }
  }
}
