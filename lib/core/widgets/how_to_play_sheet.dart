import 'package:flutter/material.dart';

import '../constants/insets.dart';
import '../constants/strings.dart';

/// A short, reusable "how to play" bottom sheet: an emoji header, a bullet
/// list of plain-language rules, and a single "Got it" dismiss button.
class HowToPlaySheet extends StatelessWidget {
  const HowToPlaySheet({
    super.key,
    required this.emoji,
    required this.title,
    required this.rules,
  });

  final String emoji;
  final String title;
  final List<String> rules;

  static Future<void> show(
    BuildContext context, {
    required String emoji,
    required String title,
    required List<String> rules,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => HowToPlaySheet(emoji: emoji, title: title, rules: rules),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.l, 0, Insets.l, Insets.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: Insets.s),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Insets.m),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final rule in rules)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Insets.s),
                          child: Text(rule, style: theme.textTheme.bodyMedium),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Insets.s),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.gotIt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
