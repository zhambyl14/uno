import 'dart:async';
import 'dart:math';

import '../domain/bot_brain.dart';
import '../domain/game_action.dart';
import '../domain/game_engine.dart';
import '../domain/game_mode.dart';
import '../domain/game_state.dart';
import '../domain/match_result.dart';
import 'game_session.dart';

/// Single-device match against bots. Owns all timers; drives bot turns and
/// enforces the per-turn clock. Fully offline.
class LocalGameSession implements GameSession {
  LocalGameSession({
    required this.localPlayerId,
    required GameState initialState,
    Random? random,
  }) : _rng = random ?? Random(),
       _state = initialState {
    _controller = StreamController<GameState>.broadcast();
    _scheduleAfterChange();
  }

  @override
  final String localPlayerId;

  final Random _rng;
  late final StreamController<GameState> _controller;
  GameState _state;
  MatchStats _stats = const MatchStats();
  Timer? _botTimer;
  Timer? _turnTimer;

  @override
  GameState get state => _state;

  @override
  Stream<GameState> get states => _controller.stream;

  @override
  MatchStats get localStats => _stats;

  static GameState createState({
    required GameMode mode,
    required List<GamePlayer> seats,
    Random? random,
  }) {
    final rng = random ?? Random();
    return GameEngine.newGame(
      roomId: 'local',
      mode: mode,
      seats: seats,
      rng: rng,
      now: DateTime.now(),
    );
  }

  @override
  void submit(GameAction action) {
    if (_state.phase == GamePhase.finished) return;
    _apply(action);
  }

  void _apply(GameAction action) {
    final previous = _state;
    final next = GameEngine.apply(
      previous,
      action,
      rng: _rng,
      now: DateTime.now(),
    );
    if (identical(next, previous)) return;
    _state = next;
    _trackLocalStats(next);
    if (!_controller.isClosed) _controller.add(next);
    _scheduleAfterChange();
  }

  void _trackLocalStats(GameState next) {
    final event = next.event;
    if (event == null || event.actorId != localPlayerId) return;
    switch (event.type) {
      case GameEventType.saidUno:
        _stats = _stats.copyWith(unosSaid: _stats.unosSaid + 1);
      case GameEventType.played || GameEventType.unoPenalty:
        _stats = _stats.copyWith(cardsPlayed: _stats.cardsPlayed + 1);
      default:
        break;
    }
  }

  void _scheduleAfterChange() {
    _botTimer?.cancel();
    _turnTimer?.cancel();
    if (_state.phase == GamePhase.finished) return;

    final current = _state.currentPlayer;
    if (current.isBot) {
      _botTimer = Timer(BotBrain.thinkDelay(_rng), _runBotTurn);
      return;
    }
    final deadline = _state.turnEndsAt;
    if (deadline != null) {
      final remaining = deadline.difference(DateTime.now());
      _turnTimer = Timer(
        remaining.isNegative ? Duration.zero : remaining,
        () => _apply(TimeoutAction(current.id)),
      );
    }
  }

  void _runBotTurn() {
    final botId = _state.currentPlayer.id;
    final actions = BotBrain.decide(_state, botId, _rng);
    for (final action in actions) {
      _apply(action);
      if (_state.phase == GamePhase.finished) return;
    }
    // If the bot could not move (no valid actions), draw to keep play going.
    if (_state.currentPlayer.id == botId && _state.phase == GamePhase.playing) {
      _apply(DrawCardAction(botId));
    }
  }

  MatchResult buildResult() =>
      MatchResult.fromState(_state, localPlayerId, _stats);

  @override
  Future<void> dispose() async {
    _botTimer?.cancel();
    _turnTimer?.cancel();
    await _controller.close();
  }
}
