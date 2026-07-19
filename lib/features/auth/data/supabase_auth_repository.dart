import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/strings.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/failures.dart';
import '../domain/player_profile.dart';
import 'auth_repository.dart';

/// Online mode: Supabase Auth + `profiles` table
/// (schema in supabase/migrations/0001_init.sql).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  static const String mobileRedirect = 'com.example.unofamily://login-callback';

  @override
  Stream<void> get authEvents => _client.auth.onAuthStateChange
      .where(
        (e) =>
            e.event == AuthChangeEvent.signedIn ||
            e.event == AuthChangeEvent.signedOut,
      )
      .map((_) {});

  @override
  Future<PlayerProfile?> restore() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _loadOrCreateProfile(user);
  }

  @override
  Future<PlayerProfile> signInGuest({
    required String nickname,
    required String avatarId,
    required bool isChild,
  }) => _guard(() async {
    final response = await _client.auth.signInAnonymously();
    return _createProfile(
      response.user!,
      nickname: nickname,
      avatarId: avatarId,
      isChild: isChild,
      isGuest: true,
    );
  });

  @override
  Future<PlayerProfile> signInEmail({
    required String email,
    required String password,
    required bool register,
    String? nickname,
    String? avatarId,
    bool isChild = false,
  }) => _guard(() async {
    final auth = _client.auth;
    final response = register
        ? await auth.signUp(email: email, password: password)
        : await auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) throw AuthFailure(S.unknownError);
    if (register) {
      if (response.session == null) {
        // "Confirm email" is on in Supabase (Authentication → Providers →
        // Email) — there's no session yet, so writing the profile row now
        // would be rejected by RLS (auth.uid() is null without a session).
        // The profile is created lazily on the first real sign-in, once
        // the user clicks the confirmation link — see _loadOrCreateProfile.
        throw AuthFailure(S.confirmEmailSent);
      }
      return _createProfile(
        user,
        nickname: nickname ?? _defaultNickname(),
        avatarId: avatarId ?? 'cat',
        isChild: isChild,
        isGuest: false,
      );
    }
    return _loadOrCreateProfile(user);
  });

  @override
  Future<void> startOAuth(OAuthKind kind) => _guard(() async {
    await _client.auth.signInWithOAuth(
      kind == OAuthKind.google ? OAuthProvider.google : OAuthProvider.apple,
      redirectTo: kIsWeb ? null : mobileRedirect,
    );
  });

  @override
  Future<PlayerProfile> updateProfile(PlayerProfile profile) =>
      _guard(() async {
        await _client
            .from('profiles')
            .update({
              'nickname': profile.nickname,
              'avatar_id': profile.avatarId,
              'xp': profile.xp,
              'coins': profile.coins,
              'rank_points': profile.rankPoints,
              'games': profile.gamesPlayed,
              'wins': profile.wins,
              'owned_items': profile.ownedItems.toList(),
              'card_skin': profile.cardSkinId,
              'table_theme': profile.tableThemeId,
            })
            .eq('id', profile.id);
        return profile;
      });

  @override
  Future<void> signOut() => _client.auth.signOut();

  Future<PlayerProfile> _loadOrCreateProfile(User user) => _guard(() async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row != null) return PlayerProfile.fromJson(row);
    return _createProfile(
      user,
      nickname: _defaultNickname(),
      avatarId: 'cat',
      isChild: false,
      isGuest: user.isAnonymous,
    );
  });

  Future<PlayerProfile> _createProfile(
    User user, {
    required String nickname,
    required String avatarId,
    required bool isChild,
    required bool isGuest,
  }) async {
    // Friend codes are unique — retry on the rare collision.
    for (var attempt = 0; attempt < 4; attempt++) {
      final profile = PlayerProfile(
        id: user.id,
        nickname: nickname,
        avatarId: avatarId,
        friendCode: CodeGen.friendCode(),
        isChild: isChild,
        isGuest: isGuest,
      );
      try {
        await _client.from('profiles').insert(profile.toJson());
        return profile;
      } on PostgrestException catch (e) {
        // 23505 = unique_violation on friend_code; try a new code.
        if (e.code != '23505' || attempt == 3) rethrow;
      }
    }
    throw NetworkFailure(S.unknownError);
  }

  String _defaultNickname() => 'player${1000 + Random().nextInt(9000)}';

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on PostgrestException {
      throw NetworkFailure(S.networkError);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw NetworkFailure(S.networkError);
    }
  }
}
