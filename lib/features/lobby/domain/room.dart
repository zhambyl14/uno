import '../../game/domain/game_mode.dart';
import '../../game/domain/game_state.dart';

enum RoomStatus { waiting, playing, closed }

class RoomPlayer {
  const RoomPlayer({
    required this.id,
    required this.name,
    required this.avatarId,
    required this.isHost,
    this.isBot = false,
  });

  final String id;
  final String name;
  final String avatarId;
  final bool isHost;
  final bool isBot;

  GamePlayer toSeat() =>
      GamePlayer(id: id, name: name, avatarId: avatarId, isBot: isBot);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar_id': avatarId,
    'is_host': isHost,
    'is_bot': isBot,
  };

  factory RoomPlayer.fromJson(Map<String, dynamic> json) => RoomPlayer(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarId: json['avatar_id'] as String,
    isHost: json['is_host'] as bool? ?? false,
    isBot: json['is_bot'] as bool? ?? false,
  );
}

class Room {
  const Room({
    required this.code,
    required this.hostId,
    required this.isPublic,
    required this.mode,
    required this.players,
    this.status = RoomStatus.waiting,
  });

  final String code;
  final String hostId;
  final bool isPublic;
  final GameMode mode;
  final List<RoomPlayer> players;
  final RoomStatus status;

  static const int maxPlayers = 8;
  static const int minPlayers = 2;

  bool get isFull => players.length >= maxPlayers;
  bool get canStart => players.length >= minPlayers;
  bool isHostId(String id) => hostId == id;

  Room copyWith({List<RoomPlayer>? players, RoomStatus? status}) => Room(
    code: code,
    hostId: hostId,
    isPublic: isPublic,
    mode: mode,
    players: players ?? this.players,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'host_id': hostId,
    'is_public': isPublic,
    'mode': mode.index,
    'status': status.index,
    'players': [for (final p in players) p.toJson()],
  };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    code: json['code'] as String,
    hostId: json['host_id'] as String,
    isPublic: json['is_public'] as bool,
    mode: GameMode.values[json['mode'] as int],
    status: RoomStatus.values[json['status'] as int],
    players: [
      for (final p in json['players'] as List)
        RoomPlayer.fromJson(p as Map<String, dynamic>),
    ],
  );
}
