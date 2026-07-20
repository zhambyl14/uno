import '../../../core/constants/strings.dart';

/// The stand-alone games that live alongside UNO under Home's "Other games".
enum MiniGame {
  memory,
  snap,
  crazy8s;

  String get label => switch (this) {
    MiniGame.memory => S.memoryTitle,
    MiniGame.snap => S.snapTitle,
    MiniGame.crazy8s => S.crazy8sTitle,
  };

  String get description => switch (this) {
    MiniGame.memory => S.memoryDesc,
    MiniGame.snap => S.snapDesc,
    MiniGame.crazy8s => S.crazy8sDesc,
  };

  String get emoji => switch (this) {
    MiniGame.memory => '🧠',
    MiniGame.snap => '👏',
    MiniGame.crazy8s => '8️⃣',
  };
}
