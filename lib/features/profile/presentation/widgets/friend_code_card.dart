import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/ui_feedback.dart';

class FriendCodeCard extends StatelessWidget {
  const FriendCodeCard({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Insets.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.yourFriendCode,
              style: theme.textTheme.labelLarge!.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: Insets.s),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    code,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) context.showSnack(S.copied);
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            const SizedBox(height: Insets.xs),
            Text(
              S.friendCodeExplain,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
