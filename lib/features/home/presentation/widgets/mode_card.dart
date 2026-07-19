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
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(Corners.l),
      child: InkWell(
        borderRadius: BorderRadius.circular(Corners.l),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Insets.m),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Corners.l),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Opacity(
            opacity: locked ? 0.55 : 1,
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (locked)
                      Icon(Icons.lock_rounded, size: 18, color: scheme.outline)
                    else if (selected)
                      Icon(Icons.check_circle_rounded, color: scheme.primary),
                  ],
                ),
                const SizedBox(height: Insets.xs),
                Flexible(
                  child: Text(
                    locked ? S.lockedBadge : mode.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
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
