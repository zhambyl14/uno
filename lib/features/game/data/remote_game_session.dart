import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/game_action.dart';
import '../domain/game_mode.dart';
import '../domain/game_state.dart';
import '../domain/match_result.dart';
import 'game_session.dart';
import 'local_game_session.dart';

/// Host-authoritative online match over Supabase.
///
/// The host runs the real engine (via an embedded [LocalGameSession], which
/// also drives bots and turn timers) and mirrors every state to
/// `rooms.game_state`. Clients render the mirrored state and post their
/// actions to `room_actions`; the host consumes and applies them.
class RemoteGameSession implements GameSession {
  RemoteGameSession._({
    required this.localPlayerId,
    required this.roomCode,
    required this.isHost,
    LocalGameSession? engine,
    required GameState initialState,
  }) : _engine = engine,
       _state = initialState {
    _controller = StreamController<GameState>.broadcast();
    if (isHost) {
      _bindHost();
    } else {
      _bindClient();
    }
  }

  /// Host: builds the authoritative match and starts mirroring it.
  factory RemoteGameSession.host({
    required String hostId,
    required String roomCode,
    required GameMode mode,
    required List<GamePlayer> seats,
  }) {
    final initial = LocalGameSession.createState(mode: mode, seats: seats);
    final engine = LocalGameSession(
      localPlayerId: hostId,
      initialState: initial,
    );
    return RemoteGameSession._(
      localPlayerId: hostId,
      roomCode: roomCode,
      isHost: true,
      engine: engine,
      initialState: initial,
    );
  }

  /// Client: renders the host's authoritative state.
  factory RemoteGameSession.client({
    required String playerId,
    required String roomCode,
    required GameState initialState,
  }) => RemoteGameSession._(
    localPlayerId: playerId,
    roomCode: roomCode,
    isHost: false,
    initialState: initialState,
  );

  @override
  final String localPlayerId;
  final String roomCode;
  final bool isHost;

  final LocalGameSession? _engine;
  GameState _state;
  MatchStats _stats = const MatchStats();
  late final StreamController<GameState> _controller;
  StreamSubscription<GameState>? _engineSub;
  StreamSubscription<List<Map<String, dynamic>>>? _actionsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _roomSub;
  final Set<int> _appliedActionIds = {};

  SupabaseClient get _db => Supabase.instance.client;

  @override
  GameState get state => _state;

  @override
  Stream<GameState> get states => _controller.stream;

  @override
  MatchStats get localStats => _engine?.localStats ?? _stats;

  void _bindHost() {
    final engine = _engine!;
    unawaited(_pushState(engine.state));
    _engineSub = engine.states.listen((state) {
      _state = state;
      if (!_controller.isClosed) _controller.add(state);
      unawaited(_pushState(state));
    });
    _actionsSub = _db
        .from('room_actions')
        .stream(primaryKey: ['id'])
        .eq('room_code', roomCode)
        .listen(_onRemoteActions);
  }

  void _bindClient() {
    _roomSub = _db
        .from('rooms')
        .stream(primaryKey: ['code'])
        .eq('code', roomCode)
        .listen(_onRoomRow);
  }

  void _onRemoteActions(List<Map<String, dynamic>> rows) {
    final engine = _engine;
    if (engine == null) return;
    final sorted = [...rows]
      ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    for (final row in sorted) {
      final id = row['id'] as int;
      if (!_appliedActionIds.add(id)) continue;
      final payload = row['action'];
      if (payload is Map<String, dynamic>) {
        engine.submit(GameAction.fromJson(payload));
      }
    }
  }

  void _onRoomRow(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return;
    final raw = rows.first['game_state'];
    if (raw is! Map<String, dynamic>) return;
    final next = GameState.fromJson(raw);
    _trackLocalStats(next);
    _state = next;
    if (!_controller.isClosed) _controller.add(next);
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

  Future<void> _pushState(GameState state) async {
    try {
      await _db
          .from('rooms')
          .update({'game_state': state.toJson()})
          .eq('code', roomCode);
    } catch (_) {
      // Transient network errors are non-fatal; the next state will retry.
    }
  }

  @override
  void submit(GameAction action) {
    if (isHost) {
      _engine?.submit(action);
      return;
    }
    // Clients post actions for the host to apply.
    unawaited(
      _db
          .from('room_actions')
          .insert({'room_code': roomCode, 'action': action.toJson()})
          .then((_) {}, onError: (_) {}),
    );
  }

  @override
  Future<void> dispose() async {
    await _engineSub?.cancel();
    await _actionsSub?.cancel();
    await _roomSub?.cancel();
    await _engine?.dispose();
    await _controller.close();
  }
}
