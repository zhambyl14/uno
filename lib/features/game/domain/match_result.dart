import 'game_mode.dart';
import 'game_state.dart';

/// What the local player did this match — feeds daily missions.
class MatchStats {
  const MatchStats({this.unosSaid = 0, this.cardsPlayed = 0});
  final int unosSaid;
  final int cardsPlayed;

  MatchStats copyWith({int? unosSaid, int? cardsPlayed}) => MatchStats(
    unosSaid: unosSaid ?? this.unosSaid,
    cardsPlayed: cardsPlayed ?? this.cardsPlayed,
  );
}

class StandingEntry {
  const StandingEntry({
    required this.name,
    required this.avatarId,
    required this.cardsLeft,
    required this.isLocal,
    required this.teamIndex,
  });
  final String name;
  final String avatarId;
  final int cardsLeft;
  final bool isLocal;
  final int teamIndex;
}

/// Final match outcome and the rewards granted to the local player.
class MatchResult {
  const MatchResult({
    required this.mode,
    required this.winnerName,
    required this.isLocalWin,
    required this.isTeam,
    required this.standings,
    required this.xpGain,
    required this.coinGain,
    required this.rankGain,
    required this.stats,
  });

  final GameMode mode;
  final String winnerName;
  final bool isLocalWin;
  final bool isTeam;
  final List<StandingEntry> standings;
  final int xpGain;
  final int coinGain;
  final int rankGain;
  final MatchStats stats;

  static const int _winXp = 25;
  static const int _playXp = 10;
  static const int _winCoins = 10;
  static const int _playCoins = 5;
  static const int _winRank = 15;
  static const int _playRank = 3;

  factory MatchResult.fromState(
    GameState state,
    String localId,
    MatchStats stats,
  ) {
    final winner = state.playerById(state.winnerId ?? '');
    final local = state.playerById(localId);
    final isTeam = state.mode.isTeam;
    final isLocalWin = isTeam && local != null && winner != null
        ? winner.teamIndex == local.teamIndex
        : state.winnerId == localId;

    final standings = [
      for (final p in state.players)
        StandingEntry(
          name: p.name,
          avatarId: p.avatarId,
          cardsLeft: p.hand.length,
          isLocal: p.id == localId,
          teamIndex: p.teamIndex,
        ),
    ]..sort((a, b) => a.cardsLeft.compareTo(b.cardsLeft));

    return MatchResult(
      mode: state.mode,
      winnerName: winner?.name ?? '',
      isLocalWin: isLocalWin,
      isTeam: isTeam,
      standings: standings,
      xpGain: isLocalWin ? _winXp : _playXp,
      coinGain: isLocalWin ? _winCoins : _playCoins,
      rankGain: isLocalWin ? _winRank : _playRank,
      stats: stats,
    );
  }
}
