import 'package:flutter/material.dart';

import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🃏',
              style: TextStyle(fontSize: 72, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: Insets.m),
            Text(
              S.appName,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Insets.xs),
            Text(
              S.tagline,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: Insets.xl),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
