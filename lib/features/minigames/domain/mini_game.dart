import '../../../core/constants/strings.dart';

/// The stand-alone games that live alongside UNO under Home's "Other games".
enum MiniGame {
  memory,
  snap;

  String get label => switch (this) {
    MiniGame.memory => S.memoryTitle,
    MiniGame.snap => S.snapTitle,
  };

  String get description => switch (this) {
    MiniGame.memory => S.memoryDesc,
    MiniGame.snap => S.snapDesc,
  };

  String get emoji => switch (this) {
    MiniGame.memory => '🧠',
    MiniGame.snap => '👏',
  };
}
