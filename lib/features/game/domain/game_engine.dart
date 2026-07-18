import 'dart:math';

import 'deck.dart';
import 'game_action.dart';
import 'game_mode.dart';
import 'game_state.dart';
import 'uno_card.dart';

/// Pure, deterministic rules engine. All mutations produce a new state;
/// invalid actions return the input state unchanged.
abstract final class GameEngine {
  static const int unoPenaltyCards = 2;

  static GameState newGame({
    required String roomId,
    required GameMode mode,
    required List<GamePlayer> seats,
    required Random rng,
    required DateTime now,
  }) {
    final deck = Deck.build(withSpecials: mode.withSpecials, rng: rng);
    final players = <GamePlayer>[];
    for (var i = 0; i < seats.length; i++) {
      final hand = deck.sublist(0, mode.handSize);
      deck.removeRange(0, mode.handSize);
      players.add(
        seats[i].copyWith(hand: hand, teamIndex: mode.isTeam ? i % 2 : -1),
      );
    }
    // Start the discard pile with a number card so the opening is simple.
    var top = deck.removeAt(0);
    while (top.type != CardType.number) {
      deck.add(top);
      top = deck.removeAt(0);
    }
    return GameState(
      roomId: roomId,
      mode: mode,
      players: players,
      drawPile: deck,
      discardPile: [top],
      activeColor: top.color,
      currentIndex: 0,
      direction: 1,
      turnEndsAt: _deadline(mode, now),
    );
  }

  static GameState apply(
    GameState s,
    GameAction action, {
    required Random rng,
    required DateTime now,
  }) {
    if (s.phase == GamePhase.finished) return s;
    switch (action) {
      case SayUnoAction():
        return _sayUno(s, action.playerId);
      case PlayCardAction():
        return _play(s, action, rng, now);
      case DrawCardAction():
        return _draw(s, action.playerId, GameEventType.drewCard, now);
      case TimeoutAction():
        return _draw(s, action.playerId, GameEventType.timeoutDraw, now);
      case LeaveAction():
        return _leave(s, action.playerId);
    }
  }

  static GameState _sayUno(GameState s, String playerId) {
    final player = s.playerById(playerId);
    if (player == null || player.hand.length != 2 || player.saidUno) return s;
    return s.copyWith(
      players: _updatePlayer(
        s.players,
        playerId,
        (p) => p.copyWith(saidUno: true),
      ),
      event: GameEvent(GameEventType.saidUno, playerId),
    );
  }

  static GameState _play(
    GameState s,
    PlayCardAction action,
    Random rng,
    DateTime now,
  ) {
    if (s.currentPlayer.id != action.playerId) return s;
    final player = s.currentPlayer;
    final cardIndex = player.hand.indexWhere((c) => c.id == action.cardId);
    if (cardIndex < 0) return s;
    final card = player.hand[cardIndex];
    if (!card.matches(
      activeColor: s.activeColor,
      top: s.topCard,
      rainbowFree: s.rainbowFree,
    )) {
      return s;
    }
    if (card.needsColorChoice && action.chosenColor == null) return s;
    if (action.chosenColor == CardColor.wild) return s;

    var hand = List.of(player.hand)..removeAt(cardIndex);
    var drawPile = List.of(s.drawPile);
    final discardPile = List.of(s.discardPile)..add(card);
    var players = List.of(s.players);
    var event = GameEvent(GameEventType.played, player.id);

    // Forgot to press UNO before going down to one card → +2 penalty.
    if (hand.length == 1 && !player.saidUno) {
      final drawn = _take(drawPile, discardPile, unoPenaltyCards);
      hand = [...hand, ...drawn];
      event = GameEvent(GameEventType.unoPenalty, player.id);
    }

    players = _updatePlayer(
      players,
      player.id,
      (p) => p.copyWith(hand: hand, saidUno: false),
    );

    if (hand.isEmpty) {
      return s.copyWith(
        players: players,
        drawPile: drawPile,
        discardPile: discardPile,
        phase: GamePhase.finished,
        winnerId: player.id,
        rainbowFree: false,
        turnEndsAt: null,
        event: GameEvent(GameEventType.win, player.id),
      );
    }

    var activeColor = card.isWildType
        ? (action.chosenColor ?? s.activeColor)
        : card.color;
    var direction = s.direction;
    var rainbowFree = false;
    var steps = 1;

    switch (card.type) {
      case CardType.number || CardType.wild:
        break;
      case CardType.skip:
        steps = 2;
        event = GameEvent(
          GameEventType.skip,
          player.id,
          players[s.nextIndex(s.currentIndex, 1)].id,
        );
      case CardType.reverse:
        direction = -direction;
        steps = players.length == 2 ? 2 : 1;
        event = GameEvent(GameEventType.reverse, player.id);
      case CardType.drawTwo:
        final result = _forceDraw(s, players, drawPile, discardPile, 2);
        players = result.players;
        drawPile = result.drawPile;
        steps = 2;
        event = GameEvent(GameEventType.drewTwo, player.id, result.targetId);
      case CardType.wildFour:
        final result = _forceDraw(s, players, drawPile, discardPile, 4);
        players = result.players;
        drawPile = result.drawPile;
        steps = 2;
        event = GameEvent(GameEventType.drewFour, player.id, result.targetId);
      case CardType.star:
        steps = 0;
        event = GameEvent(GameEventType.extraTurn, player.id);
      case CardType.gift:
        if (hand.length > 1) {
          final giftCard = hand[rng.nextInt(hand.length)];
          final targetId = players[s.nextIndex(s.currentIndex, 1)].id;
          players = _updatePlayer(
            players,
            player.id,
            (p) => p.copyWith(hand: List.of(p.hand)..remove(giftCard)),
          );
          players = _updatePlayer(
            players,
            targetId,
            (p) => p.copyWith(hand: [...p.hand, giftCard], saidUno: false),
          );
          event = GameEvent(GameEventType.gift, player.id, targetId);
        }
      case CardType.shuffle:
        final all = <UnoCard>[for (final p in players) ...p.hand];
        all.shuffle(rng);
        final counts = _fairSplit(all.length, players.length);
        var cursor = 0;
        final dealt = <String, List<UnoCard>>{};
        for (var i = 0; i < players.length; i++) {
          final seat = s.nextIndex(s.currentIndex, 1 + i);
          dealt[players[seat].id] = all.sublist(cursor, cursor + counts[i]);
          cursor += counts[i];
        }
        players = [
          for (final p in players)
            p.copyWith(hand: dealt[p.id], saidUno: false),
        ];
        event = GameEvent(GameEventType.shuffleHands, player.id);
      case CardType.rainbow:
        rainbowFree = true;
        activeColor = CardColor.wild;
        event = GameEvent(GameEventType.rainbow, player.id);
    }

    final nextIndex = s.nextIndex(s.currentIndex, steps);
    return s.copyWith(
      players: players,
      drawPile: drawPile,
      discardPile: discardPile,
      activeColor: activeColor,
      currentIndex: nextIndex,
      direction: direction,
      rainbowFree: rainbowFree,
      turnEndsAt: _deadline(s.mode, now),
      event: event,
    );
  }

  static GameState _draw(
    GameState s,
    String playerId,
    GameEventType eventType,
    DateTime now,
  ) {
    if (s.currentPlayer.id != playerId) return s;
    final drawPile = List.of(s.drawPile);
    final discardPile = List.of(s.discardPile);
    final drawn = _take(drawPile, discardPile, 1);
    final players = _updatePlayer(
      s.players,
      playerId,
      (p) => p.copyWith(hand: [...p.hand, ...drawn], saidUno: false),
    );
    return s.copyWith(
      players: players,
      drawPile: drawPile,
      discardPile: discardPile,
      currentIndex: s.nextIndex(s.currentIndex, 1),
      rainbowFree: s.rainbowFree,
      turnEndsAt: _deadline(s.mode, now),
      event: GameEvent(eventType, playerId),
    );
  }

  static GameState _leave(GameState s, String playerId) {
    if (s.playerById(playerId) == null) return s;
    final players = _updatePlayer(
      s.players,
      playerId,
      (p) => p.copyWith(isBot: true),
    );
    return s.copyWith(players: players);
  }

  /// Draws [count] cards, reshuffling the discard pile (minus its top card)
  /// into the draw pile when it runs dry.
  static List<UnoCard> _take(
    List<UnoCard> drawPile,
    List<UnoCard> discardPile,
    int count,
  ) {
    final drawn = <UnoCard>[];
    for (var i = 0; i < count; i++) {
      if (drawPile.isEmpty && discardPile.length > 1) {
        final top = discardPile.removeLast();
        drawPile.addAll(discardPile..shuffle());
        discardPile
          ..clear()
          ..add(top);
      }
      if (drawPile.isEmpty) break;
      drawn.add(drawPile.removeAt(0));
    }
    return drawn;
  }

  static ({List<GamePlayer> players, List<UnoCard> drawPile, String targetId})
  _forceDraw(
    GameState s,
    List<GamePlayer> players,
    List<UnoCard> drawPile,
    List<UnoCard> discardPile,
    int count,
  ) {
    final targetId = players[s.nextIndex(s.currentIndex, 1)].id;
    final drawn = _take(drawPile, discardPile, count);
    final updated = _updatePlayer(
      players,
      targetId,
      (p) => p.copyWith(hand: [...p.hand, ...drawn], saidUno: false),
    );
    return (players: updated, drawPile: drawPile, targetId: targetId);
  }

  static List<GamePlayer> _updatePlayer(
    List<GamePlayer> players,
    String id,
    GamePlayer Function(GamePlayer) update,
  ) => [for (final p in players) p.id == id ? update(p) : p];

  static List<int> _fairSplit(int total, int parts) {
    final base = total ~/ parts;
    final extra = total % parts;
    return [for (var i = 0; i < parts; i++) base + (i < extra ? 1 : 0)];
  }

  static DateTime? _deadline(GameMode mode, DateTime now) =>
      mode.turnSeconds == null
      ? null
      : now.add(Duration(seconds: mode.turnSeconds!));
}
