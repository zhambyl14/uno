import 'package:flutter_test/flutter_test.dart';
import 'package:uno_family/features/game/domain/game_mode.dart';
import 'package:uno_family/features/game/domain/game_state.dart';
import 'package:uno_family/features/game/domain/match_result.dart';
import 'package:uno_family/features/game/domain/uno_card.dart';

GamePlayer p(String id, int cards, {int team = -1}) => GamePlayer(
  id: id,
  name: id,
  avatarId: 'cat',
  isBot: id != 'me',
  teamIndex: team,
  hand: List.generate(
    cards,
    (i) => UnoCard(
      id: '$id$i',
      color: CardColor.red,
      type: CardType.number,
      number: i % 10,
    ),
  ),
);

GameState finished({
  required List<GamePlayer> players,
  required String winnerId,
  GameMode mode = GameMode.classic,
}) => GameState(
  roomId: 'r',
  mode: mode,
  players: players,
  drawPile: const [],
  discardPile: const [
    UnoCard(id: 't', color: CardColor.red, type: CardType.number, number: 5),
  ],
  activeColor: CardColor.red,
  currentIndex: 0,
  direction: 1,
  phase: GamePhase.finished,
  winnerId: winnerId,
);

void main() {
  test('local win grants the win rewards', () {
    final state = finished(players: [p('me', 0), p('bot', 3)], winnerId: 'me');
    final result = MatchResult.fromState(state, 'me', const MatchStats());
    expect(result.isLocalWin, isTrue);
    expect(result.xpGain, 25);
    expect(result.coinGain, 10);
    expect(result.rankGain, 15);
  });

  test('local loss grants the play rewards', () {
    final state = finished(players: [p('me', 4), p('bot', 0)], winnerId: 'bot');
    final result = MatchResult.fromState(state, 'me', const MatchStats());
    expect(result.isLocalWin, isFalse);
    expect(result.xpGain, 10);
    expect(result.coinGain, 5);
  });

  test('team win counts when a teammate finishes first', () {
    final state = finished(
      mode: GameMode.team,
      players: [
        p('me', 2, team: 0),
        p('rival', 3, team: 1),
        p('mate', 0, team: 0),
        p('rival2', 4, team: 1),
      ],
      winnerId: 'mate',
    );
    final result = MatchResult.fromState(state, 'me', const MatchStats());
    expect(result.isLocalWin, isTrue);
  });

  test('standings are sorted by fewest cards left', () {
    final state = finished(
      players: [p('me', 5), p('bot', 0), p('bot2', 2)],
      winnerId: 'bot',
    );
    final result = MatchResult.fromState(state, 'me', const MatchStats());
    expect(result.standings.first.cardsLeft, 0);
    expect(result.standings.last.cardsLeft, 5);
  });
}
