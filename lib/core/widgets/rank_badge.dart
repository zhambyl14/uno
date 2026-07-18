import 'package:flutter/material.dart';

import '../constants/insets.dart';
import '../constants/strings.dart';
import '../utils/rank.dart';

class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.points, this.showProgress = true});
  final int points;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final tier = RankTier.fromPoints(points);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Insets.s),
              decoration: BoxDecoration(
                color: tier.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Corners.m),
              ),
              child: Icon(Icons.workspace_premium_rounded, color: tier.color),
            ),
            const SizedBox(width: Insets.m),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier.label, style: theme.textTheme.titleMedium),
                Text(
                  S.rankPointsLabel(points),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (showProgress) ...[
          const SizedBox(height: Insets.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(Corners.s),
            child: LinearProgressIndicator(
              value: RankTier.progress(points),
              minHeight: 8,
              color: tier.color,
            ),
          ),
        ],
      ],
    );
  }
}
