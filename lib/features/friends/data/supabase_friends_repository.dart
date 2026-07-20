import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/strings.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/failures.dart';
import '../domain/friend.dart';
import '../domain/game_invite.dart';
import 'friends_repository.dart';

/// Online friends via the `friendships` table + `profiles` lookup by code.
/// Schema: supabase/migrations/0001_init.sql.
class SupabaseFriendsRepository implements FriendsRepository {
  SupabaseClient get _db => Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;
  String? get _uidOrNull => _db.auth.currentUser?.id;

  @override
  Future<List<Friend>> list() => _guard(() async {
    final uid = _uidOrNull;
    if (uid == null) return <Friend>[];
    final rows = await _db
        .from('friendships')
        .select(
          'friend:profiles!friendships_friend_id_fkey('
          'id, nickname, avatar_id, friend_code)',
        )
        .eq('user_id', uid);
    return [
      for (final row in rows)
        Friend.fromJson(row['friend'] as Map<String, dynamic>),
    ];
  });

  @override
  Future<Friend> addByCode({required String code, required String myCode}) =>
      _guard(() async {
        final normalized = CodeGen.normalize(code);
        if (!CodeGen.friendCodePattern.hasMatch(normalized)) {
          throw ValidationFailure(S.invalidFriendCode);
        }
        if (normalized == myCode) {
          throw ValidationFailure(S.cantAddSelf);
        }
        final row = await _db
            .from('profiles')
            .select('id, nickname, avatar_id, friend_code')
            .eq('friend_code', normalized)
            .maybeSingle();
        if (row == null) throw NotFoundFailure(S.friendNotFound);
        final friend = Friend.fromJson(row);

        final existing = await _db
            .from('friendships')
            .select('friend_id')
            .eq('user_id', _uid)
            .eq('friend_id', friend.id)
            .maybeSingle();
        if (existing != null) {
          throw ValidationFailure(S.alreadyFriends);
        }

        // Symmetric friendship: both directions inserted.
        await _db.from('friendships').insert([
          {'user_id': _uid, 'friend_id': friend.id},
          {'user_id': friend.id, 'friend_id': _uid},
        ]);
        return friend;
      });

  @override
  Future<void> remove(String friendId) => _guard(() async {
    await _db
        .from('friendships')
        .delete()
        .or(
          'and(user_id.eq.$_uid,friend_id.eq.$friendId),'
          'and(user_id.eq.$friendId,friend_id.eq.$_uid)',
        );
  });

  @override
  Future<void> inviteToRoom({
    required String friendId,
    required String roomCode,
  }) => _guard(() async {
    // The row both drives the recipient's realtime in-app banner and the
    // friend "invite" push (send-push Edge Function).
    await _db.from('invites').insert({
      'from_id': _uid,
      'to_id': friendId,
      'room_code': roomCode,
    });
  });

  @override
  Stream<List<GameInvite>> watchInvites() {
    final uid = _uidOrNull;
    if (uid == null) return Stream.value(const <GameInvite>[]);
    return _db
        .from('invites')
        .stream(primaryKey: ['id'])
        .eq('to_id', uid)
        .map(
          (rows) => [
            for (final row in rows)
              if (row['room_code'] != null) GameInvite.fromJson(row),
          ],
        );
  }

  @override
  Future<void> consumeInvite(int inviteId) =>
      _guard(() async => _db.from('invites').delete().eq('id', inviteId));

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
