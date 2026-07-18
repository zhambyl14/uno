import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/catalog.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/failures.dart';
import '../domain/friend.dart';
import 'supabase_friends_repository.dart';

abstract class FriendsRepository {
  Future<List<Friend>> list();

  /// Adds a friend by code. Throws a typed [AppFailure] on any problem.
  Future<Friend> addByCode({required String code, required String myCode});

  Future<void> remove(String friendId);

  /// Sends a game invite to a friend (push in online mode).
  Future<void> invite(String friendId);
}

/// Offline friends list persisted on-device. Since there is no user
/// directory offline, adding a code creates a local contact entry so the
/// friends list is fully usable without a backend.
class LocalFriendsRepository implements FriendsRepository {
  LocalFriendsRepository(this._prefs);
  final PrefsService _prefs;
  static const _key = 'friends';
  final Random _rng = Random();

  List<Friend> _read() {
    final json = _prefs.getJson(_key);
    if (json == null) return [];
    return [
      for (final f in json['items'] as List? ?? const [])
        Friend.fromJson(f as Map<String, dynamic>),
    ];
  }

  Future<void> _write(List<Friend> friends) => _prefs.setJson(_key, {
    'items': [for (final f in friends) f.toJson()],
  });

  @override
  Future<List<Friend>> list() async => _read();

  @override
  Future<Friend> addByCode({
    required String code,
    required String myCode,
  }) async {
    final normalized = CodeGen.normalize(code);
    if (!CodeGen.friendCodePattern.hasMatch(normalized)) {
      throw ValidationFailure(S.invalidFriendCode);
    }
    if (normalized == myCode) {
      throw ValidationFailure(S.cantAddSelf);
    }
    final friends = _read();
    if (friends.any((f) => f.friendCode == normalized)) {
      throw ValidationFailure(S.alreadyFriends);
    }
    final avatar = Avatars.free[_rng.nextInt(Avatars.free.length)];
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    final friend = Friend(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      nickname: S.placeholderFriendName(digits.substring(digits.length - 4)),
      avatarId: avatar.id,
      friendCode: normalized,
    );
    await _write([...friends, friend]);
    return friend;
  }

  @override
  Future<void> remove(String friendId) async {
    await _write(_read().where((f) => f.id != friendId).toList());
  }

  @override
  Future<void> invite(String friendId) async {
    // No backend offline; the UI shows a confirmation only.
  }
}

final friendsRepositoryProvider = Provider<FriendsRepository>(
  (ref) => AppConfig.isOnline
      ? SupabaseFriendsRepository()
      : LocalFriendsRepository(ref.watch(prefsServiceProvider)),
);
