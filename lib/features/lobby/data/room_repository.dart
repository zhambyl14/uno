import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/catalog.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/failures.dart';
import '../../game/domain/game_mode.dart';
import '../../game/domain/game_state.dart';
import '../domain/room.dart';
import 'supabase_room_repository.dart';

abstract class RoomRepository {
  Future<Room> createRoom({
    required bool isPublic,
    required GameMode mode,
    required RoomPlayer host,
  });

  Future<Room> joinRoom({required String code, required RoomPlayer player});

  /// Public matchmaking: join an open room or create one.
  Future<Room> quickMatch({required GameMode mode, required RoomPlayer player});

  Stream<Room?> watchRoom(String code);
  Future<void> addBot(String code);
  Future<void> leaveRoom({required String code, required String playerId});
  Future<void> startGame(String code);

  /// Online only: the host's mirrored game state, for a joining client.
  Future<GameState?> currentGameState(String code);
}

/// Offline rooms: a practice room the host fills with bots. State lives in
/// memory for this app instance (there is no server to reach in local mode).
class LocalRoomRepository implements RoomRepository {
  final Map<String, Room> _rooms = {};
  final Map<String, StreamController<Room?>> _controllers = {};
  final Random _rng = Random();

  @override
  Future<Room> createRoom({
    required bool isPublic,
    required GameMode mode,
    required RoomPlayer host,
  }) async {
    final code = _uniqueCode();
    final room = Room(
      code: code,
      hostId: host.id,
      isPublic: isPublic,
      mode: mode,
      players: [host],
    );
    _rooms[code] = room;
    return room;
  }

  @override
  Future<Room> joinRoom({
    required String code,
    required RoomPlayer player,
  }) async {
    // No shared server offline — only rooms created on this device exist.
    final room = _rooms[CodeGen.normalize(code)];
    if (room == null || room.status != RoomStatus.waiting) {
      throw NotFoundFailure(S.roomNotFound);
    }
    if (room.players.any((p) => p.id == player.id)) return room;
    final updated = room.copyWith(players: [...room.players, player]);
    _emit(updated);
    return updated;
  }

  @override
  Future<Room> quickMatch({
    required GameMode mode,
    required RoomPlayer player,
  }) async {
    // Offline quick match = a bot-filled public room.
    final room = await createRoom(isPublic: true, mode: mode, host: player);
    return room;
  }

  @override
  Stream<Room?> watchRoom(String code) {
    final key = CodeGen.normalize(code);
    final controller = _controllers.putIfAbsent(
      key,
      () => StreamController<Room?>.broadcast(),
    );
    scheduleMicrotask(() => controller.add(_rooms[key]));
    return controller.stream;
  }

  @override
  Future<void> addBot(String code) async {
    final key = CodeGen.normalize(code);
    final room = _rooms[key];
    if (room == null || room.isFull) return;
    final used = room.players.map((p) => p.name).toSet();
    final name = BotNames.all.firstWhere(
      (n) => !used.contains(n),
      orElse: () => BotNames.all[_rng.nextInt(BotNames.all.length)],
    );
    final avatar = Avatars.free[_rng.nextInt(Avatars.free.length)];
    final bot = RoomPlayer(
      id: 'bot_${room.players.length}_${_rng.nextInt(9999)}',
      name: name,
      avatarId: avatar.id,
      isHost: false,
      isBot: true,
    );
    _emit(room.copyWith(players: [...room.players, bot]));
  }

  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    final key = CodeGen.normalize(code);
    final room = _rooms[key];
    if (room == null) return;
    if (room.hostId == playerId) {
      _emit(room.copyWith(status: RoomStatus.closed));
      _rooms.remove(key);
      return;
    }
    _emit(
      room.copyWith(
        players: room.players.where((p) => p.id != playerId).toList(),
      ),
    );
  }

  @override
  Future<void> startGame(String code) async {
    final key = CodeGen.normalize(code);
    final room = _rooms[key];
    if (room == null) return;
    _emit(room.copyWith(status: RoomStatus.playing));
  }

  @override
  Future<GameState?> currentGameState(String code) async => null;

  void _emit(Room room) {
    _rooms[room.code] = room;
    _controllers[room.code]?.add(room);
  }

  String _uniqueCode() {
    var code = CodeGen.roomCode(_rng);
    while (_rooms.containsKey(code)) {
      code = CodeGen.roomCode(_rng);
    }
    return code;
  }
}

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  if (AppConfig.isOnline) return SupabaseRoomRepository();
  final repo = LocalRoomRepository();
  return repo;
});
