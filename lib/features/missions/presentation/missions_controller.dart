import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/prefs_service.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/mission.dart';

/// Daily missions. Progress resets each calendar day; rewards are coins,
/// credited to the profile on claim.
class MissionsController extends Notifier<DailyMissionsState> {
  static const _key = 'missions';

  PrefsService get _prefs => ref.read(prefsServiceProvider);

  static String _todayKey(DateTime now) =>
      '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';

  @override
  DailyMissionsState build() {
    final today = _todayKey(DateTime.now());
    final json = _prefs.getJson(_key);
    if (json == null) return DailyMissionsState.fresh(today);
    final saved = DailyMissionsState.fromJson(json);
    return saved.day == today ? saved : DailyMissionsState.fresh(today);
  }

  void recordGamePlayed({required bool won, required int unosSaid}) {
    _bump(MissionKind.playGame, 1);
    if (unosSaid > 0) _bump(MissionKind.sayUno, unosSaid);
    if (won) _bump(MissionKind.win, 1);
  }

  void recordCardsPlayed(int count) => _bump(MissionKind.playCards, count);

  void _bump(MissionKind kind, int amount) {
    final entries = List.of(state.entries);
    for (var i = 0; i < Missions.daily.length; i++) {
      if (Missions.daily[i].kind != kind) continue;
      final target = Missions.daily[i].target;
      final next = (entries[i].progress + amount).clamp(0, target);
      entries[i] = entries[i].copyWith(progress: next);
    }
    _persist(DailyMissionsState(day: state.day, entries: entries));
  }

  /// Claims a completed mission, crediting its coin reward to the profile.
  Future<void> claim(int index) async {
    if (!state.isComplete(index) || state.entries[index].claimed) return;
    final entries = List.of(state.entries)
      ..[index] = state.entries[index].copyWith(claimed: true);
    _persist(DailyMissionsState(day: state.day, entries: entries));

    final auth = ref.read(authControllerProvider.notifier);
    final profile = auth.profile;
    if (profile != null) {
      await auth.creditCoins(Missions.daily[index].reward);
    }
  }

  void _persist(DailyMissionsState next) {
    state = next;
    unawaited(_prefs.setJson(_key, next.toJson()));
  }
}

final missionsControllerProvider =
    NotifierProvider<MissionsController, DailyMissionsState>(
      MissionsController.new,
    );
