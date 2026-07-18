import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/failures.dart';
import '../domain/player_profile.dart';
import 'supabase_auth_repository.dart';

enum OAuthKind { google, apple }

abstract class AuthRepository {
  /// Restores an existing session, or null when signed out.
  Future<PlayerProfile?> restore();

  /// Fires when an external auth event happens (OAuth redirect completed,
  /// session expired). The controller re-restores on each event.
  Stream<void> get authEvents;

  Future<PlayerProfile> signInGuest({
    required String nickname,
    required String avatarId,
    required bool isChild,
  });

  Future<PlayerProfile> signInEmail({
    required String email,
    required String password,
    required bool register,
    String? nickname,
    String? avatarId,
    bool isChild = false,
  });

  Future<void> startOAuth(OAuthKind kind);

  Future<PlayerProfile> updateProfile(PlayerProfile profile);

  Future<void> signOut();
}

/// Local mode: a guest profile persisted on this device. Social sign-in
/// requires the online build (Supabase).
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs);
  final PrefsService _prefs;
  static const _key = 'profile';

  @override
  Stream<void> get authEvents => const Stream.empty();

  @override
  Future<PlayerProfile?> restore() async {
    final json = _prefs.getJson(_key);
    return json == null ? null : PlayerProfile.fromJson(json);
  }

  @override
  Future<PlayerProfile> signInGuest({
    required String nickname,
    required String avatarId,
    required bool isChild,
  }) async {
    final profile = PlayerProfile(
      id: 'local-${Random().nextInt(1 << 31)}',
      nickname: nickname,
      avatarId: avatarId,
      friendCode: CodeGen.friendCode(),
      isChild: isChild,
      isGuest: true,
    );
    await _prefs.setJson(_key, profile.toJson());
    return profile;
  }

  @override
  Future<PlayerProfile> signInEmail({
    required String email,
    required String password,
    required bool register,
    String? nickname,
    String? avatarId,
    bool isChild = false,
  }) => throw OfflineFailure(S.onlineOnlyBody);

  @override
  Future<void> startOAuth(OAuthKind kind) =>
      throw OfflineFailure(S.onlineOnlyBody);

  @override
  Future<PlayerProfile> updateProfile(PlayerProfile profile) async {
    await _prefs.setJson(_key, profile.toJson());
    return profile;
  }

  @override
  Future<void> signOut() => _prefs.remove(_key);
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AppConfig.isOnline
      ? SupabaseAuthRepository()
      : LocalAuthRepository(ref.watch(prefsServiceProvider)),
);
