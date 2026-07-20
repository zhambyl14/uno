import 'package:flutter/material.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';
import '../../../game/domain/game_mode.dart';

class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.mode,
    required this.selected,
    required this.locked,
    required this.onTap,
  });
  final GameMode mode;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = mode.gradientColors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Corners.l),
      child: InkWell(
        borderRadius: BorderRadius.circular(Corners.l),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Insets.m),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(Corners.l),
            border: Border.all(
              color: selected ? Colors.white : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Opacity(
            opacity: locked ? 0.6 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(mode.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: Insets.s),
                    Expanded(
                      child: Text(
                        mode.label,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (locked)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    else if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                  ],
                ),
                const SizedBox(height: Insets.xs),
                Flexible(
                  child: Text(
                    locked ? S.lockedBadge : mode.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
