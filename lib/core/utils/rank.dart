import 'dart:ui';

import '../constants/strings.dart';

/// Soft, non-toxic progression: points only go up.
enum RankTier {
  bronze(S.rankBronze, 0, Color(0xFFB08D57)),
  silver(S.rankSilver, 100, Color(0xFF9BA8B5)),
  gold(S.rankGold, 250, Color(0xFFE3B341)),
  platinum(S.rankPlatinum, 500, Color(0xFF7FD1CB)),
  diamond(S.rankDiamond, 900, Color(0xFF7FB3F0));

  const RankTier(this.label, this.minPoints, this.color);
  final String label;
  final int minPoints;
  final Color color;

  static RankTier fromPoints(int points) {
    var result = RankTier.bronze;
    for (final tier in RankTier.values) {
      if (points >= tier.minPoints) result = tier;
    }
    return result;
  }

  /// Progress towards the next tier, 0..1 (diamond stays full).
  static double progress(int points) {
    final current = fromPoints(points);
    if (current == RankTier.diamond) return 1;
    final next = RankTier.values[current.index + 1];
    final span = next.minPoints - current.minPoints;
    return (points - current.minPoints) / span;
  }
}

/// Season = current month (soft monthly reset of cosmetic rewards only).
String seasonName(DateTime now) => S.seasonLabel(S.monthNames[now.month - 1]);
