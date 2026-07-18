import 'package:flutter/material.dart';

import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/adaptive_scaffold.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.privacyPolicy)),
      body: ContentWidth(
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.all(Insets.l),
            children: [
              Row(
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: Insets.m),
                  Expanded(
                    child: Text(
                      S.appName,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Insets.l),
              Text(
                S.privacyBody,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
