import 'package:flutter/material.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';
import '../../domain/uno_card.dart';
import 'uno_card_view.dart';

/// Prompts the player to choose a color after a wild-type card.
class ColorPickerSheet extends StatelessWidget {
  const ColorPickerSheet({super.key});

  static Future<CardColor?> show(BuildContext context) {
    return showModalBottomSheet<CardColor>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const ColorPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colors = [
      CardColor.red,
      CardColor.yellow,
      CardColor.green,
      CardColor.blue,
    ];
    return Padding(
      padding: const EdgeInsets.all(Insets.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.chooseColor, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: Insets.l),
          Wrap(
            spacing: Insets.m,
            runSpacing: Insets.m,
            alignment: WrapAlignment.center,
            children: [
              for (final color in colors)
                InkWell(
                  borderRadius: BorderRadius.circular(Corners.l),
                  onTap: () => Navigator.of(context).pop(color),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: UnoCardView.colorOf(color),
                      borderRadius: BorderRadius.circular(Corners.l),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Insets.m),
        ],
      ),
    );
  }
}
