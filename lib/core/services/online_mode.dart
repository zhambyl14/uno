import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_config.dart';

/// Whether the app talks to Supabase. It starts from the compile-time
/// [AppConfig.isOnline] flag, but the auth layer can drop it to `false` at
/// runtime (see [OnlineMode.forceOffline]) when the backend can't be reached —
/// so the game is ALWAYS playable (bots, shop, missions) even with no network
/// or with anonymous sign-in disabled. Every repository provider watches this,
/// so flipping it swaps them all to their local implementations at once.
class OnlineMode extends Notifier<bool> {
  @override
  bool build() => AppConfig.isOnline;

  /// Fall back to fully-local mode after an unrecoverable backend failure.
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
