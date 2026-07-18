import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_family/features/game/domain/deck.dart';
import 'package:uno_family/features/game/domain/game_action.dart';
import 'package:uno_family/features/game/domain/game_engine.dart';
import 'package:uno_family/features/game/domain/game_mode.dart';
import 'package:uno_family/features/game/domain/game_state.dart';
import 'package:uno_family/features/game/domain/uno_card.dart';

UnoCard card(String id, CardColor color, CardType type, [int number = -1]) =>
    UnoCard(id: id, color: color, type: type, number: number);

GamePlayer player(String id, List<UnoCard> hand, {bool saidUno = false}) =>
    GamePlayer(
      id: id,
      name: id,
      avatarId: 'cat',
      isBot: false,
      hand: hand,
      saidUno: saidUno,
    );

GameState state({
  required List<GamePlayer> players,
  required UnoCard top,
  List<UnoCard> drawPile = const [],
  int currentIndex = 0,
  int direction = 1,
  CardColor? activeColor,
  bool rainbowFree = false,
  GameMode mode = GameMode.classic,
}) => GameState(
  roomId: 'test',
  mode: mode,
  players: players,
  drawPile: drawPile,
  discardPile: [top],
  activeColor: activeColor ?? top.color,
  currentIndex: currentIndex,
  direction: direction,
  rainbowFree: rainbowFree,
);

final _rng = Random(7);
final _now = DateTime(2026);

GameState apply(GameState s, GameAction a) =>
    GameEngine.apply(s, a, rng: _rng, now: _now);

void main() {
  group('Deck', () {
    test('standard deck has 108 cards', () {
      expect(Deck.build(withSpecials: false, rng: Random(1)).length, 108);
    });

    test('deck with specials has 124 cards', () {
      expect(Deck.build(withSpecials: true, rng: Random(1)).length, 124);
    });
  });

  group('newGame', () {
    test('deals hands and starts on a number card', () {
      final seats = [
        player('a', const []),
        player('b', const []),
        player('c', const []),
      ];
      final game = GameEngine.newGame(
        roomId: 'r',
        mode: GameMode.classic,
        seats: seats,
        rng: Random(3),
        now: _now,
      );
      expect(game.players.length, 3);
      for (final p in game.players) {
        expect(p.hand.length, GameMode.classic.handSize);
      }
      expect(game.topCard.type, CardType.number);
      // 124 special deck - 3*7 dealt - 1 on discard.
      expect(game.drawPile.length, 124 - 21 - 1);
    });

    test('team mode assigns alternating teams', () {
      final seats = List.generate(4, (i) => player('p$i', const []));
      final game = GameEngine.newGame(
        roomId: 'r',
        mode: GameMode.team,
        seats: seats,
        rng: Random(3),
        now: _now,
      );
      expect(game.players.map((p) => p.teamIndex).toList(), [0, 1, 0, 1]);
    });
  });

  group('playing cards', () {
    test('matching number card advances turn and moves to discard', () {
      final s = state(
        players: [
          player('a', [
            card('x', CardColor.red, CardType.number, 5),
            card('keep', CardColor.green, CardType.number, 1),
          ], saidUno: true),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 9),
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      expect(next.currentIndex, 1);
      expect(next.topCard.id, 'x');
      expect(next.playerById('a')!.hand.single.id, 'keep');
    });

    test('non-matching card is rejected (state unchanged)', () {
      final s = state(
        players: [
          player('a', [card('x', CardColor.blue, CardType.number, 5)]),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 9),
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      expect(identical(next, s), isTrue);
    });

    test('playing the last card wins the game', () {
      final s = state(
        players: [
          player('a', [
            card('x', CardColor.red, CardType.number, 5),
          ], saidUno: true),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      expect(next.phase, GamePhase.finished);
      expect(next.winnerId, 'a');
    });

    test('forgetting UNO at two cards adds a 2-card penalty', () {
      final s = state(
        players: [
          player('a', [
            card('x', CardColor.red, CardType.number, 5),
            card('y', CardColor.green, CardType.number, 3),
          ]),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
        drawPile: [
          card('d1', CardColor.blue, CardType.number, 1),
          card('d2', CardColor.blue, CardType.number, 2),
        ],
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      // Played 1, would have 1 left, +2 penalty => 3 cards.
      expect(next.playerById('a')!.hand.length, 3);
      expect(next.event!.type, GameEventType.unoPenalty);
    });

    test('saying UNO at two cards avoids the penalty', () {
      final s = state(
        players: [
          player('a', [
            card('x', CardColor.red, CardType.number, 5),
            card('y', CardColor.green, CardType.number, 3),
          ]),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final said = apply(s, const SayUnoAction('a'));
      expect(said.playerById('a')!.saidUno, isTrue);
      final next = apply(said, const PlayCardAction('a', cardId: 'x'));
      expect(next.playerById('a')!.hand.length, 1);
    });
  });

  group('action cards', () {
    // Filler cards keep the actor's hand above one, so the action resolves
    // instead of ending the game (an emptied hand always wins first).
    List<UnoCard> withFiller(UnoCard action) => [
      action,
      card('f1', CardColor.green, CardType.number, 7),
      card('f2', CardColor.green, CardType.number, 8),
    ];

    test('skip jumps over the next player', () {
      final s = state(
        players: [
          player('a', withFiller(card('x', CardColor.red, CardType.skip))),
          player('b', const []),
          player('c', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      expect(next.currentIndex, 2); // b skipped
    });

    test('draw two makes the next player draw and skips them', () {
      final s = state(
        players: [
          player('a', withFiller(card('x', CardColor.red, CardType.drawTwo))),
          player('b', const []),
          player('c', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
        drawPile: [
          card('d1', CardColor.blue, CardType.number, 1),
          card('d2', CardColor.blue, CardType.number, 2),
        ],
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      expect(next.playerById('b')!.hand.length, 2);
      expect(next.currentIndex, 2);
    });

    test('wild sets the chosen active color', () {
      final s = state(
        players: [
          player('a', withFiller(card('w', CardColor.wild, CardType.wild))),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final next = apply(
        s,
        const PlayCardAction('a', cardId: 'w', chosenColor: CardColor.blue),
      );
      expect(next.activeColor, CardColor.blue);
    });

    test('wild without a chosen color is rejected', () {
      final s = state(
        players: [
          player('a', [card('w', CardColor.wild, CardType.wild)]),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'w'));
      expect(identical(next, s), isTrue);
    });

    test('star grants an extra turn (same player)', () {
      final s = state(
        players: [
          player('a', [
            card('x', CardColor.red, CardType.star),
            card('y', CardColor.red, CardType.number, 1),
          ]),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      expect(next.currentIndex, 0);
      expect(next.event!.type, GameEventType.extraTurn);
    });

    test('rainbow lets the next player play any color', () {
      final s = state(
        players: [
          player('a', withFiller(card('x', CardColor.wild, CardType.rainbow))),
          player('b', const []),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final next = apply(s, const PlayCardAction('a', cardId: 'x'));
      expect(next.rainbowFree, isTrue);
      expect(next.activeColor, CardColor.wild);
    });
  });

  group('draw and timeout', () {
    test('drawing advances the turn', () {
      final s = state(
        players: [player('a', const []), player('b', const [])],
        top: card('top', CardColor.red, CardType.number, 5),
        drawPile: [card('d1', CardColor.blue, CardType.number, 1)],
      );
      final next = apply(s, const DrawCardAction('a'));
      expect(next.playerById('a')!.hand.length, 1);
      expect(next.currentIndex, 1);
    });

    test('timeout forces the current player to draw', () {
      final s = state(
        players: [player('a', const []), player('b', const [])],
        top: card('top', CardColor.red, CardType.number, 5),
        drawPile: [card('d1', CardColor.blue, CardType.number, 1)],
      );
      final next = apply(s, const TimeoutAction('a'));
      expect(next.event!.type, GameEventType.timeoutDraw);
      expect(next.currentIndex, 1);
    });

    test('a card played out of turn is rejected', () {
      final s = state(
        players: [
          player('a', [card('x', CardColor.red, CardType.number, 5)]),
          player('b', [card('y', CardColor.red, CardType.number, 6)]),
        ],
        top: card('top', CardColor.red, CardType.number, 5),
      );
      final next = apply(s, const PlayCardAction('b', cardId: 'y'));
      expect(identical(next, s), isTrue);
    });
  });

  group('deterministic full game', () {
    test('a bot-vs-bot style loop always terminates with a winner', () {
      // Drive random legal actions until someone wins; guards against
      // deadlocks/among-turn stalls in the engine.
      var s = GameEngine.newGame(
        roomId: 'r',
        mode: GameMode.fast,
        seats: List.generate(3, (i) => player('p$i', const [])),
        rng: Random(11),
        now: _now,
      );
      final rng = Random(11);
      var guard = 0;
      while (s.phase == GamePhase.playing && guard < 5000) {
        guard++;
        final me = s.currentPlayer;
        final playable = me.hand
            .where(
              (c) => c.matches(
                activeColor: s.activeColor,
                top: s.topCard,
                rainbowFree: s.rainbowFree,
              ),
            )
            .toList();
        if (me.hand.length == 2 && !me.saidUno) {
          s = apply(s, SayUnoAction(me.id));
        }
        if (playable.isEmpty) {
          s = apply(s, DrawCardAction(me.id));
        } else {
          final c = playable[rng.nextInt(playable.length)];
          s = apply(
            s,
            PlayCardAction(
              me.id,
              cardId: c.id,
              chosenColor: c.needsColorChoice ? CardColor.red : null,
            ),
          );
        }
      }
      expect(s.phase, GamePhase.finished);
      expect(s.winnerId, isNotNull);
    });
  });
}
