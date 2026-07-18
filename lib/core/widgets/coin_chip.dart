import 'package:flutter/material.dart';

import '../constants/insets.dart';

class CoinChip extends StatelessWidget {
  const CoinChip({super.key, required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.m,
        vertical: Insets.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Corners.l),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 16)),
          const SizedBox(width: Insets.xs),
          Text(
            '$coins',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
