import '../domain/game_action.dart';
import '../domain/game_state.dart';
import '../domain/match_result.dart';

/// A running match. Implemented locally (bots) or remotely (Supabase).
abstract class GameSession {
  String get localPlayerId;
  GameState get state;
  Stream<GameState> get states;

  /// Cumulative actions of the local player, used for daily missions.
  MatchStats get localStats;

  void submit(GameAction action);
  Future<void> dispose();
}
