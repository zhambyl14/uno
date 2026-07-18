import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/prefs_service.dart';
import '../../../core/services/push_service.dart';

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.soundOn = true,
    this.notifInvites = true,
    this.notifDaily = true,
    this.notifSeason = true,
  });

  final ThemeMode themeMode;
  final bool soundOn;
  final bool notifInvites;
  final bool notifDaily;
  final bool notifSeason;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? soundOn,
    bool? notifInvites,
    bool? notifDaily,
    bool? notifSeason,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    soundOn: soundOn ?? this.soundOn,
    notifInvites: notifInvites ?? this.notifInvites,
    notifDaily: notifDaily ?? this.notifDaily,
    notifSeason: notifSeason ?? this.notifSeason,
  );

  Map<String, dynamic> toJson() => {
    'theme': themeMode.index,
    'sound': soundOn,
    'n_invites': notifInvites,
    'n_daily': notifDaily,
    'n_season': notifSeason,
  };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
    themeMode: ThemeMode.values[json['theme'] as int? ?? 0],
    soundOn: json['sound'] as bool? ?? true,
    notifInvites: json['n_invites'] as bool? ?? true,
    notifDaily: json['n_daily'] as bool? ?? true,
    notifSeason: json['n_season'] as bool? ?? true,
  );
}

class SettingsController extends Notifier<SettingsState> {
  static const _key = 'settings';

  PrefsService get _prefs => ref.read(prefsServiceProvider);

  @override
  SettingsState build() {
    final json = _prefs.getJson(_key);
    return json == null ? const SettingsState() : SettingsState.fromJson(json);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setSound(bool on) => _update(state.copyWith(soundOn: on));

  Future<void> setNotifInvites(bool on) =>
      _update(state.copyWith(notifInvites: on), syncPush: true);
  Future<void> setNotifDaily(bool on) =>
      _update(state.copyWith(notifDaily: on), syncPush: true);
  Future<void> setNotifSeason(bool on) =>
      _update(state.copyWith(notifSeason: on), syncPush: true);

  Future<void> _update(SettingsState next, {bool syncPush = false}) async {
    state = next;
    await _prefs.setJson(_key, next.toJson());
    if (syncPush) {
      await ref
          .read(pushServiceProvider)
          .updateTopics(
            invites: next.notifInvites,
            daily: next.notifDaily,
            season: next.notifSeason,
          );
    }
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
