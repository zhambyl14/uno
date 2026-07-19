import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../data/auth_repository.dart';
import 'auth_controller.dart';
import 'widgets/email_auth_sheet.dart';

/// Reached only as an opt-in upgrade (from a locked mode or the Profile
/// tab) — never a blocking gate. A guest profile already exists by the
/// time this screen can be shown; signing in here unlocks the rest.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _oauth(
    BuildContext context,
    WidgetRef ref,
    OAuthKind kind,
  ) async {
    if (!AppConfig.isOnline) {
      await _showOnlineOnly(context);
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).startOAuth(kind);
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  Future<void> _email(BuildContext context) async {
    if (!AppConfig.isOnline) {
      await _showOnlineOnly(context);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: Insets.l),
        child: EmailAuthSheet(),
      ),
    );
  }

  Future<void> _showOnlineOnly(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.onlineOnlyTitle),
        content: Text(S.onlineOnlyBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Insets.l, 0, Insets.l, Insets.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🌍',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 56),
                ),
                const SizedBox(height: Insets.m),
                Text(
                  S.loginTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Insets.xs),
                Text(
                  S.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Insets.l),
                const _PerkList(),
                const SizedBox(height: Insets.xl),
                _SignInButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: S.signInGoogle,
                  filled: true,
                  onPressed: () => _oauth(context, ref, OAuthKind.google),
                ),
                _SignInButton(
                  icon: Icons.apple,
                  label: S.signInApple,
                  onPressed: () => _oauth(context, ref, OAuthKind.apple),
                ),
                _SignInButton(
                  icon: Icons.mail_outline,
                  label: S.signInEmail,
                  onPressed: () => _email(context),
                ),
                if (!AppConfig.isOnline) ...[
                  const SizedBox(height: Insets.m),
                  const _LocalModeNote(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerkList extends StatelessWidget {
  const _PerkList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final perks = [
      (Icons.style_rounded, S.unlockPerkModes),
      (Icons.groups_rounded, S.unlockPerkFriends),
      (Icons.emoji_events_rounded, S.unlockPerkLeaderboard),
      (Icons.sync_rounded, S.unlockPerkSync),
    ];
    return Container(
      padding: const EdgeInsets.all(Insets.m),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Corners.l),
      ),
      child: Column(
        children: [
          for (final (icon, label) in perks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.xs),
              child: Row(
                children: [
                  Icon(icon, color: scheme.onSecondaryContainer, size: 20),
                  const SizedBox(width: Insets.s),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: Insets.s),
        Text(label),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.s),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: filled
            ? FilledButton(onPressed: onPressed, child: child)
            : OutlinedButton(onPressed: onPressed, child: child),
      ),
    );
  }
}

class _LocalModeNote extends StatelessWidget {
  const _LocalModeNote();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Insets.m),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Corners.m),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 20),
          const SizedBox(width: Insets.s),
          Expanded(
            child: Text(
              '${S.localModeBadge}: ${S.onlineOnlyBody}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
