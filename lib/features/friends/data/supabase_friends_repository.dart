import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/strings.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/failures.dart';
import '../domain/friend.dart';
import 'friends_repository.dart';

/// Online friends via the `friendships` table + `profiles` lookup by code.
/// Schema: supabase/migrations/0001_init.sql.
class SupabaseFriendsRepository implements FriendsRepository {
  SupabaseClient get _db => Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  @override
  Future<List<Friend>> list() => _guard(() async {
    final rows = await _db
        .from('friendships')
        .select(
          'friend:profiles!friendships_friend_id_fkey('
          'id, nickname, avatar_id, friend_code)',
        )
        .eq('user_id', _uid);
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
  Future<void> invite(String friendId) => _guard(() async {
    // A row here triggers the friend's "invite" push (Edge Function).
    await _db.from('invites').insert({'from_id': _uid, 'to_id': friendId});
  });

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
