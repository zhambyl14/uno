import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/catalog.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/online_mode.dart';
import '../../../core/services/push_service.dart';
import '../../../core/utils/failures.dart';
import '../../../core/utils/nickname_filter.dart';
import '../data/auth_repository.dart';
import '../domain/player_profile.dart';

/// Session state for the whole app. Kept alive while the app runs.
///
/// The app never blocks on a login screen: a nameless visitor becomes a
/// guest automatically on first launch (see [_autoGuest]) and can start
/// playing Classic mode immediately. Signing in for real (Google/Apple/
/// Email) is an upgrade a guest opts into later to unlock the rest.
class AuthController extends AsyncNotifier<PlayerProfile?> {
  StreamSubscription<void>? _subscription;

  @override
  Future<PlayerProfile?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    await _subscription?.cancel();
    _subscription = repo.authEvents.listen((_) => ref.invalidateSelf());
    ref.onDispose(() => _subscription?.cancel());
    final profile = await _restoreOrGuest(repo);
    if (profile != null) {
      unawaited(ref.read(pushServiceProvider).syncToken(profile.id));
    }
    return profile;
  }

  /// Restore an existing session, else create a guest. Never throws — a
  /// backend hiccup must not strand the app on the splash screen.
  Future<PlayerProfile?> _restoreOrGuest(AuthRepository repo) async {
    try {
      final restored = await repo.restore();
      if (restored != null) return restored;
    } catch (_) {
      // No usable session — fall through to a guest.
    }
    return _autoGuest(repo);
  }

  /// Creates the automatic guest. If the online backend rejects anonymous
  /// sign-in (Anonymous auth disabled, or no network), it drops the whole app
  /// to fully-local mode and retries with the local guest — which always
  /// succeeds — so the player is never stranded profile-less. The provider
  /// swap re-runs [build] with the local repositories.
  Future<PlayerProfile?> _autoGuest(AuthRepository repo) async {
    try {
      final rng = Random();
      final avatar = Avatars.free[rng.nextInt(Avatars.free.length)];
      return await repo.signInGuest(
        nickname: 'player${1000 + rng.nextInt(9000)}',
        avatarId: avatar.id,
        isChild: false,
      );
    } catch (_) {
      // Defer: a provider can't be mutated during another provider's build.
      if (ref.read(isOnlineProvider)) {
        unawaited(
          Future(() {
            if (ref.mounted) {
              ref.read(isOnlineProvider.notifier).forceOffline();
            }
          }),
        );
      }
      return null;
    }
  }

  PlayerProfile? get profile => state.value;

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> signInGuest({
    required String nickname,
    required String avatarId,
    required bool isChild,
  }) async {
    _validateNickname(nickname);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signInGuest(
        nickname: nickname.trim(),
        avatarId: avatarId,
        isChild: isChild,
      ),
    );
    await _syncPush();
  }

  Future<void> signInEmail({
    required String email,
    required String password,
    required bool register,
    String? nickname,
    String? avatarId,
    bool isChild = false,
  }) async {
    if (register && nickname != null) _validateNickname(nickname);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signInEmail(
        email: email.trim(),
        password: password,
        register: register,
        nickname: nickname?.trim(),
        avatarId: avatarId,
        isChild: isChild,
      ),
    );
    await _syncPush();
  }

  /// OAuth completes via redirect; authEvents triggers the rebuild (which
  /// syncs the push token itself, see [build]).
  Future<void> startOAuth(OAuthKind kind) => _repo.startOAuth(kind);

  Future<void> signOut() async {
    await ref.read(pushServiceProvider).syncToken(null);
    await _repo.signOut();
    ref.invalidateSelf();
  }

  Future<void> _syncPush() async {
    final id = profile?.id;
    if (id != null) await ref.read(pushServiceProvider).syncToken(id);
  }

  Future<void> updateNicknameAndAvatar({
    required String nickname,
    required String avatarId,
  }) async {
    final current = profile;
    if (current == null) return;
    _validateNickname(nickname);
    await _persist(
      current.copyWith(nickname: nickname.trim(), avatarId: avatarId),
    );
  }

  Future<void> applyMatchResult({
    required bool won,
    required int xpGain,
    required int coinGain,
    required int rankGain,
  }) async {
    final current = profile;
    if (current == null) return;
    await _persist(
      current.afterMatch(
        won: won,
        xpGain: xpGain,
        coinGain: coinGain,
        rankGain: rankGain,
      ),
    );
  }

  /// Credits coins (e.g. a claimed daily mission reward).
  Future<void> creditCoins(int amount) async {
    final current = profile;
    if (current == null || amount <= 0) return;
    await _persist(current.copyWith(coins: current.coins + amount));
  }

  /// Fixed-price cosmetic purchase — no randomness, no pay-to-win.
  Future<void> purchase(String itemId, int price) async {
    final current = profile;
    if (current == null) return;
    if (current.ownedItems.contains(itemId)) return;
    if (current.coins < price) {
      throw ValidationFailure(S.notEnoughCoins);
    }
    await _persist(
      current.copyWith(
        coins: current.coins - price,
        ownedItems: {...current.ownedItems, itemId},
      ),
    );
  }

  Future<void> equipCardSkin(String skinId) async {
    final current = profile;
    if (current == null) return;
    await _persist(current.copyWith(cardSkinId: skinId));
  }

  Future<void> equipTableTheme(String themeId) async {
    final current = profile;
    if (current == null) return;
    await _persist(current.copyWith(tableThemeId: themeId));
  }

  Future<void> _persist(PlayerProfile updated) async {
    state = AsyncData(await _repo.updateProfile(updated));
  }

  void _validateNickname(String nickname) {
    final error = NicknameFilter.validate(nickname);
    if (error != null) throw ValidationFailure(error);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, PlayerProfile?>(AuthController.new);
