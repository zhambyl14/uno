import 'game_mode.dart';
import 'uno_card.dart';

enum GamePhase { playing, finished }

enum GameEventType {
  played,
  drewCard,
  timeoutDraw,
  skip,
  reverse,
  drewTwo,
  drewFour,
  passed,
  extraTurn,
  gift,
  shuffleHands,
  rainbow,
  saidUno,
  unoPenalty,
  win,
}

/// The single announcement produced by the last applied action.
class GameEvent {
  const GameEvent(this.type, this.actorId, [this.targetId]);
  final GameEventType type;
  final String actorId;
  final String? targetId;

  Map<String, dynamic> toJson() => {
    't': type.index,
    'a': actorId,
    'g': targetId,
  };

  factory GameEvent.fromJson(Map<String, dynamic> json) => GameEvent(
    GameEventType.values[json['t'] as int],
    json['a'] as String,
    json['g'] as String?,
  );
}

class GamePlayer {
  const GamePlayer({
    required this.id,
    required this.name,
    required this.avatarId,
    required this.isBot,
    this.teamIndex = -1,
    this.hand = const [],
    this.saidUno = false,
  });

  final String id;
  final String name;
  final String avatarId;
  final bool isBot;

  /// 0 or 1 in Team mode, -1 otherwise.
  final int teamIndex;
  final List<UnoCard> hand;
  final bool saidUno;

  GamePlayer copyWith({
    List<UnoCard>? hand,
    bool? saidUno,
    bool? isBot,
    int? teamIndex,
  }) => GamePlayer(
    id: id,
    name: name,
    avatarId: avatarId,
    isBot: isBot ?? this.isBot,
    teamIndex: teamIndex ?? this.teamIndex,
    hand: hand ?? this.hand,
    saidUno: saidUno ?? this.saidUno,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatarId,
    'bot': isBot,
    'team': teamIndex,
    'uno': saidUno,
    'hand': [for (final c in hand) c.toJson()],
  };

  factory GamePlayer.fromJson(Map<String, dynamic> json) => GamePlayer(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarId: json['avatar'] as String,
    isBot: json['bot'] as bool,
    teamIndex: json['team'] as int,
    saidUno: json['uno'] as bool,
    hand: [
      for (final c in json['hand'] as List)
        UnoCard.fromJson(c as Map<String, dynamic>),
    ],
  );
}

class GameState {
  const GameState({
    required this.roomId,
    required this.mode,
    required this.players,
    required this.drawPile,
    required this.discardPile,
    required this.activeColor,
    required this.currentIndex,
    required this.direction,
    this.rainbowFree = false,
    this.phase = GamePhase.playing,
    this.winnerId,
    this.turnEndsAt,
    this.drawnCardId,
    this.event,
  });

  final String roomId;
  final GameMode mode;
  final List<GamePlayer> players;
  final List<UnoCard> drawPile;

  /// Last element is the top of the pile.
  final List<UnoCard> discardPile;
  final CardColor activeColor;
  final int currentIndex;

  /// 1 = clockwise, -1 = counter-clockwise.
  final int direction;

  /// Set by 🌈 Rainbow: for one turn any card matches.
  final bool rainbowFree;
  final GamePhase phase;
  final String? winnerId;
  final DateTime? turnEndsAt;

  /// The only card that may be played after the current player draws.
  /// A null value means the player has not drawn during this turn.
  final String? drawnCardId;
  final GameEvent? event;

  GamePlayer get currentPlayer => players[currentIndex];
  UnoCard get topCard => discardPile.last;

  GamePlayer? playerById(String id) {
    for (final p in players) {
      if (p.id == id) return p;
    }
    return null;
  }

  int nextIndex(int from, int steps) {
    final n = players.length;
    return ((from + direction * steps) % n + n) % n;
  }

  static const _unset = Object();

  GameState copyWith({
    List<GamePlayer>? players,
    List<UnoCard>? drawPile,
    List<UnoCard>? discardPile,
    CardColor? activeColor,
    int? currentIndex,
    int? direction,
    bool? rainbowFree,
    GamePhase? phase,
    String? winnerId,
    DateTime? turnEndsAt,
    Object? drawnCardId = _unset,
    GameEvent? event,
  }) => GameState(
    roomId: roomId,
    mode: mode,
    players: players ?? this.players,
    drawPile: drawPile ?? this.drawPile,
    discardPile: discardPile ?? this.discardPile,
    activeColor: activeColor ?? this.activeColor,
    currentIndex: currentIndex ?? this.currentIndex,
    direction: direction ?? this.direction,
    rainbowFree: rainbowFree ?? this.rainbowFree,
    phase: phase ?? this.phase,
    winnerId: winnerId ?? this.winnerId,
    turnEndsAt: turnEndsAt ?? this.turnEndsAt,
    drawnCardId: identical(drawnCardId, _unset)
        ? this.drawnCardId
        : drawnCardId as String?,
    event: event ?? this.event,
  );

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'mode': mode.index,
    'players': [for (final p in players) p.toJson()],
    'draw': [for (final c in drawPile) c.toJson()],
    'discard': [for (final c in discardPile) c.toJson()],
    'color': activeColor.index,
    'current': currentIndex,
    'dir': direction,
    'rainbow': rainbowFree,
    'phase': phase.index,
    'winner': winnerId,
    'endsAt': turnEndsAt?.millisecondsSinceEpoch,
    'drawn': drawnCardId,
    'event': event?.toJson(),
  };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    roomId: json['roomId'] as String,
    mode: GameMode.values[json['mode'] as int],
    players: [
      for (final p in json['players'] as List)
        GamePlayer.fromJson(p as Map<String, dynamic>),
    ],
    drawPile: [
      for (final c in json['draw'] as List)
        UnoCard.fromJson(c as Map<String, dynamic>),
    ],
    discardPile: [
      for (final c in json['discard'] as List)
        UnoCard.fromJson(c as Map<String, dynamic>),
    ],
    activeColor: CardColor.values[json['color'] as int],
    currentIndex: json['current'] as int,
    direction: json['dir'] as int,
    rainbowFree: json['rainbow'] as bool,
    phase: GamePhase.values[json['phase'] as int],
    winnerId: json['winner'] as String?,
    turnEndsAt: json['endsAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['endsAt'] as int),
    drawnCardId: json['drawn'] as String?,
    event: json['event'] == null
        ? null
        : GameEvent.fromJson(json['event'] as Map<String, dynamic>),
  );
}
