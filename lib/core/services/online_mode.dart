import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_config.dart';

/// Whether the app talks to Supabase. Mirrors the compile-time
/// [AppConfig.isOnline] flag for the app's lifetime — repositories
/// (auth/friends/rooms) all watch this so Login/registration always reach
/// the real backend when one is configured. A failed *silent* guest
/// auto-login (e.g. Anonymous auth disabled) must NOT flip this to false:
/// that used to accidentally block manual sign-in too. See
/// `AuthController._autoGuest`, which instead falls back to a local-only
/// guest profile without touching this flag.
class OnlineMode extends Notifier<bool> {
  @override
  bool build() => AppConfig.isOnline;

  /// Retained for tests / explicit opt-out only — never called from the
  /// normal auth flow (a failed auto-guest must not disable real sign-in).
  void forceOffline() {
    if (state) state = false;
  }
}

final isOnlineProvider = NotifierProvider<OnlineMode, bool>(OnlineMode.new);

/// Test helper: pins online mode to a fixed value.
/// Use `isOnlineProvider.overrideWith(() => FixedOnlineMode(false))`.
class FixedOnlineMode extends OnlineMode {
  FixedOnlineMode(this._value);
  final bool _value;

  @override
  bool build() => _value;

  @override
  void forceOffline() {}
}
