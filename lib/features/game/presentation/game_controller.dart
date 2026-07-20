import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../missions/presentation/missions_controller.dart';
import '../data/game_session.dart';
import '../data/local_game_session.dart';
import '../domain/game_action.dart';
import '../domain/game_mode.dart';
import '../domain/game_state.dart';
import '../domain/match_result.dart';
import '../domain/seat_factory.dart';

/// Owns the active match. Null when no game is in progress.
class GameController extends Notifier<GameSession?> {
  @override
  GameSession? build() {
    ref.onDispose(() {
      final session = state;
      if (session != null) unawaited(session.dispose());
    });
    return null;
  }

  /// Solo match against bots (Home "quick play").
  void startLocal({
    required GameMode mode,
    int botCount = SeatFactory.defaultBotCount,
  }) {
    final me = ref.read(authControllerProvider).value;
    if (me == null) return;
    final seats = SeatFactory.withBots(me: me, botCount: botCount);
    _replace(
      LocalGameSession(
        localPlayerId: me.id,
        initialState: LocalGameSession.createState(mode: mode, seats: seats),
      ),
    );
  }

  /// Match from an explicit seat list (a lobby room, topped up with bots).
  void startWithSeats({
    required GameMode mode,
    required List<GamePlayer> seats,
    required String localId,
  }) {
    _replace(
      LocalGameSession(
        localPlayerId: localId,
        initialState: LocalGameSession.createState(mode: mode, seats: seats),
      ),
    );
  }

  /// Attach an externally-built session (e.g. Supabase remote match).
  void attach(GameSession session) => _replace(session);

  void _replace(GameSession session) {
    final previous = state;
    if (previous != null) unawaited(previous.dispose());
    state = session;
  }

  void submit(GameAction action) => state?.submit(action);

  /// Finalizes the match: stores the result for the results screen right
  /// away, then best-effort syncs rewards/missions to the profile in the
  /// background. A slow or unreachable backend must never leave the player
  /// stuck staring at a frozen game screen after they've already won.
  Future<void> endAndAward() async {
    final session = state;
    if (session == null) return;
    final result = MatchResult.fromState(
      session.state,
      session.localPlayerId,
      session.localStats,
    );
    state = null; // guard against a double award
    ref.read(lastResultProvider.notifier).set(result);

    unawaited(
      ref
          .read(authControllerProvider.notifier)
          .applyMatchResult(
            won: result.isLocalWin,
            xpGain: result.xpGain,
            coinGain: result.coinGain,
            rankGain: result.rankGain,
          )
          .timeout(const Duration(seconds: 8), onTimeout: () {})
          .catchError((_) {}),
    );
    try {
      final missions = ref.read(missionsControllerProvider.notifier);
      missions.recordGamePlayed(
        won: result.isLocalWin,
        unosSaid: result.stats.unosSaid,
      );
      missions.recordCardsPlayed(result.stats.cardsPlayed);
    } catch (_) {
      // Missions are a nice-to-have; never let them block finishing a match.
    }
    await session.dispose();
  }
}

final gameControllerProvider = NotifierProvider<GameController, GameSession?>(
  GameController.new,
);

/// Live game state stream for the UI (current value first, then updates).
final gameStateProvider = StreamProvider.autoDispose<GameState>((ref) async* {
  final session = ref.watch(gameControllerProvider);
  if (session == null) return;
  yield session.state;
  yield* session.states;
});

/// Holds the most recent finished-match result for the results screen.
class LastResult extends Notifier<MatchResult?> {
  @override
  MatchResult? build() => null;
  void set(MatchResult result) => state = result;
  void clear() => state = null;
}

final lastResultProvider = NotifierProvider<LastResult, MatchResult?>(
  LastResult.new,
);
