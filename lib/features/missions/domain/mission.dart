import '../../../core/constants/strings.dart';

enum MissionKind { playGame, sayUno, playCards, win }

class MissionDef {
  const MissionDef(this.kind, this.target, this.reward);
  final MissionKind kind;
  final int target;
  final int reward;

  /// A getter (not a stored field): it is localized and `S.locale` can
  /// change at runtime, while `MissionDef` instances stay const.
  String get title => switch (kind) {
    MissionKind.playGame => S.missionPlayOne,
    MissionKind.sayUno => S.missionSayUno,
    MissionKind.playCards => S.missionPlayCards,
    MissionKind.win => S.missionWinOne,
  };
}

abstract final class Missions {
  static const List<MissionDef> daily = [
    MissionDef(MissionKind.playGame, 1, 20),
    MissionDef(MissionKind.sayUno, 3, 25),
    MissionDef(MissionKind.playCards, 15, 20),
    MissionDef(MissionKind.win, 1, 40),
  ];
}

/// Progress + claimed flag for one mission on the current day.
class MissionProgress {
  const MissionProgress({this.progress = 0, this.claimed = false});
  final int progress;
  final bool claimed;

  MissionProgress copyWith({int? progress, bool? claimed}) => MissionProgress(
    progress: progress ?? this.progress,
    claimed: claimed ?? this.claimed,
  );

  Map<String, dynamic> toJson() => {'p': progress, 'c': claimed};

  factory MissionProgress.fromJson(Map<String, dynamic> json) =>
      MissionProgress(
        progress: json['p'] as int? ?? 0,
        claimed: json['c'] as bool? ?? false,
      );
}

class DailyMissionsState {
  const DailyMissionsState({required this.day, required this.entries});

  /// Day key `yyyy-mm-dd`; used to reset progress at midnight.
  final String day;
  final List<MissionProgress> entries;

  int get claimableCount {
    var count = 0;
    for (var i = 0; i < Missions.daily.length; i++) {
      if (_isComplete(i) && !entries[i].claimed) count++;
    }
    return count;
  }

  bool _isComplete(int index) =>
      entries[index].progress >= Missions.daily[index].target;

  bool isComplete(int index) => _isComplete(index);

  Map<String, dynamic> toJson() => {
    'day': day,
    'entries': [for (final e in entries) e.toJson()],
  };

  factory DailyMissionsState.fromJson(Map<String, dynamic> json) =>
      DailyMissionsState(
        day: json['day'] as String,
        entries: [
          for (final e in json['entries'] as List)
            MissionProgress.fromJson(e as Map<String, dynamic>),
        ],
      );

  static DailyMissionsState fresh(String day) => DailyMissionsState(
    day: day,
    entries: List.filled(Missions.daily.length, const MissionProgress()),
  );
}
