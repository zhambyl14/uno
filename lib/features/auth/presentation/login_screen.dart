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
import 'widgets/profile_setup_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _sheet(BuildContext context, Widget child) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Insets.l),
        child: child,
      ),
    );
  }

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

  Future<void> _email(BuildContext context) {
    if (!AppConfig.isOnline) return _showOnlineOnly(context);
    return _sheet(context, const EmailAuthSheet());
  }

  Future<void> _guest(BuildContext context, WidgetRef ref) {
    return _sheet(
      context,
      _GuestSetup(
        onSubmit: (nickname, avatarId, isChild) async {
          try {
            await ref
                .read(authControllerProvider.notifier)
                .signInGuest(
                  nickname: nickname,
                  avatarId: avatarId,
                  isChild: isChild,
                );
            if (context.mounted) Navigator.of(context).pop();
          } catch (error) {
            if (context.mounted) context.showError(error);
          }
        },
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
      body: SafeArea(
        child: ContentWidth(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Insets.l),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: Insets.xl),
                const Text('🃏', style: TextStyle(fontSize: 64)),
                const SizedBox(height: Insets.m),
                Text(
                  S.loginTitle,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Insets.s),
                Text(
                  S.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Insets.xl),
                _SignInButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: S.signInGoogle,
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
                const SizedBox(height: Insets.s),
                const _OrDivider(),
                const SizedBox(height: Insets.s),
                _SignInButton(
                  icon: Icons.sports_esports_outlined,
                  label: S.playAsGuest,
                  filled: true,
                  onPressed: () => _guest(context, ref),
                ),
                if (!AppConfig.isOnline) ...[
                  const SizedBox(height: Insets.l),
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

/// Wraps the shared profile setup form for guest sign-in inside a sheet.
class _GuestSetup extends StatelessWidget {
  const _GuestSetup({required this.onSubmit});
  final void Function(String, String, bool) onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + Insets.l,
      ),
      child: ProfileSetupForm(submitLabel: S.startPlaying, onSubmit: onSubmit),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Insets.m),
          child: Text('•'),
        ),
        Expanded(child: Divider()),
      ],
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
