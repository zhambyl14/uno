import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/catalog.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/failures.dart';
import '../../game/domain/game_mode.dart';
import '../../game/domain/game_state.dart';
import '../domain/room.dart';
import 'room_repository.dart';

/// Online rooms backed by the `rooms` table + Realtime.
/// Schema: supabase/migrations/0001_init.sql.
class SupabaseRoomRepository implements RoomRepository {
  SupabaseClient get _db => Supabase.instance.client;
  final Random _rng = Random();

  @override
  Future<Room> createRoom({
    required bool isPublic,
    required GameMode mode,
    required RoomPlayer host,
  }) => _guard(() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = CodeGen.roomCode(_rng);
      final room = Room(
        code: code,
        hostId: host.id,
        isPublic: isPublic,
        mode: mode,
        players: [host],
      );
      try {
        await _db.from('rooms').insert(room.toJson());
        return room;
      } on PostgrestException catch (e) {
        if (e.code != '23505') rethrow; // duplicate code, retry
      }
    }
    throw NetworkFailure(S.unknownError);
  });

  @override
  Future<Room> joinRoom({required String code, required RoomPlayer player}) =>
      _guard(() async {
        final normalized = CodeGen.normalize(code);
        final room = await _fetch(normalized);
        if (room == null || room.status != RoomStatus.waiting) {
          throw NotFoundFailure(S.roomNotFound);
        }
        if (room.isFull) throw NotFoundFailure(S.roomNotFound);
        if (room.players.any((p) => p.id == player.id)) return room;
        final updated = room.copyWith(players: [...room.players, player]);
        await _save(updated);
        return updated;
      });

  @override
  Future<Room> quickMatch({
    required GameMode mode,
    required RoomPlayer player,
  }) => _guard(() async {
    final rows = await _db
        .from('rooms')
        .select()
        .eq('is_public', true)
        .eq('status', RoomStatus.waiting.index)
        .eq('mode', mode.index)
        .limit(10);
    for (final row in rows) {
      final room = Room.fromJson(row);
      if (!room.isFull) {
        return joinRoom(code: room.code, player: player);
      }
    }
    return createRoom(isPublic: true, mode: mode, host: player);
  });

  @override
  Stream<Room?> watchRoom(String code) {
    final normalized = CodeGen.normalize(code);
    return _db
        .from('rooms')
        .stream(primaryKey: ['code'])
        .eq('code', normalized)
        .map((rows) => rows.isEmpty ? null : Room.fromJson(rows.first));
  }

  @override
  Future<void> addBot(String code) => _guard(() async {
    final normalized = CodeGen.normalize(code);
    final room = await _fetch(normalized);
    if (room == null || room.isFull) return;
    final used = room.players.map((p) => p.name).toSet();
    final name = BotNames.all.firstWhere(
      (n) => !used.contains(n),
      orElse: () => BotNames.all[_rng.nextInt(BotNames.all.length)],
    );
    final bot = RoomPlayer(
      id: 'bot_${room.players.length}_${_rng.nextInt(9999)}',
      name: name,
      avatarId: Avatars.free[_rng.nextInt(Avatars.free.length)].id,
      isHost: false,
      isBot: true,
    );
    await _save(room.copyWith(players: [...room.players, bot]));
  });

  @override
  Future<void> leaveRoom({required String code, required String playerId}) =>
      _guard(() async {
        final normalized = CodeGen.normalize(code);
        final room = await _fetch(normalized);
        if (room == null) return;
        if (room.hostId == playerId) {
          await _db.from('rooms').delete().eq('code', normalized);
          return;
        }
        await _save(
          room.copyWith(
            players: room.players.where((p) => p.id != playerId).toList(),
          ),
        );
      });

  @override
  Future<void> startGame(String code) => _guard(() async {
    await _db
        .from('rooms')
        .update({'status': RoomStatus.playing.index})
        .eq('code', CodeGen.normalize(code));
  });

  @override
  Future<GameState?> currentGameState(String code) => _guard(() async {
    final row = await _db
        .from('rooms')
        .select('game_state')
        .eq('code', CodeGen.normalize(code))
        .maybeSingle();
    final raw = row?['game_state'];
    return raw is Map<String, dynamic> ? GameState.fromJson(raw) : null;
  });

  Future<Room?> _fetch(String code) async {
    final row = await _db.from('rooms').select().eq('code', code).maybeSingle();
    return row == null ? null : Room.fromJson(row);
  }

  Future<void> _save(Room room) async {
    await _db
        .from('rooms')
        .update({
          'players': [for (final p in room.players) p.toJson()],
          'status': room.status.index,
        })
        .eq('code', room.code);
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppFailure {
      rethrow;
    } on PostgrestException {
      throw NetworkFailure(S.networkError);
    } catch (_) {
      throw NetworkFailure(S.networkError);
    }
  }
}
