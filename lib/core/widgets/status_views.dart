import 'package:flutter/material.dart';

import '../constants/insets.dart';
import '../constants/strings.dart';
import '../utils/failures.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is AppFailure
        ? (error as AppFailure).message
        : S.unknownError;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: Insets.m),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: Insets.m),
              FilledButton.tonal(onPressed: onRetry, child: Text(S.retry)),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.hint,
    this.emoji = '🃏',
    this.action,
  });
  final String title;
  final String? hint;
  final String emoji;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: Insets.m),
            Text(title, style: theme.textTheme.titleMedium),
            if (hint != null) ...[
              const SizedBox(height: Insets.s),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: Insets.m), action!],
          ],
        ),
      ),
    );
  }
}
