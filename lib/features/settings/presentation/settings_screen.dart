import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../auth/presentation/auth_controller.dart';
import 'locale_controller.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.0.0';

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.signOut),
        content: Text(S.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(S.signOut),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(S.settingsTitle)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(Insets.l),
          children: [
            _SectionTitle(S.appearance),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(S.themeSystem),
                  icon: const Icon(Icons.brightness_auto_rounded),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(S.themeLight),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(S.themeDark),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => controller.setThemeMode(s.first),
            ),
            const SizedBox(height: Insets.m),
            _SectionTitle(S.languageLabel),
            SegmentedButton<AppLocale>(
              segments: [
                for (final locale in AppLocale.values)
                  ButtonSegment(value: locale, label: Text(locale.label)),
              ],
              selected: {locale},
              onSelectionChanged: (s) => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(s.first),
            ),
            const SizedBox(height: Insets.m),
            SwitchListTile(
              title: Text(S.soundLabel),
              secondary: const Icon(Icons.volume_up_outlined),
              value: settings.soundOn,
              onChanged: controller.setSound,
            ),
            const Divider(),
            _SectionTitle(S.notificationsTitle),
            if (!AppConfig.pushReady)
              Padding(
                padding: const EdgeInsets.only(bottom: Insets.s),
                child: _InfoNote(text: S.pushNotConfigured),
              ),
            SwitchListTile(
              title: Text(S.notifInvites),
              secondary: const Icon(Icons.person_add_alt_1_outlined),
              value: settings.notifInvites,
              onChanged: AppConfig.pushReady
                  ? controller.setNotifInvites
                  : null,
            ),
            SwitchListTile(
              title: Text(S.notifDaily),
              secondary: const Icon(Icons.card_giftcard_outlined),
              value: settings.notifDaily,
              onChanged: AppConfig.pushReady ? controller.setNotifDaily : null,
            ),
            SwitchListTile(
              title: Text(S.notifSeason),
              secondary: const Icon(Icons.emoji_events_outlined),
              value: settings.notifSeason,
              onChanged: AppConfig.pushReady ? controller.setNotifSeason : null,
            ),
            const Divider(),
            _SectionTitle(S.aboutTitle),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(S.privacyPolicy),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.privacy),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text(S.appName),
              subtitle: Text(S.versionLabel(_appVersion)),
            ),
            const SizedBox(height: Insets.m),
            FilledButton.tonalIcon(
              onPressed: () => _signOut(context, ref),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              icon: const Icon(Icons.logout_rounded),
              label: Text(S.signOut),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.s),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});
  final String text;

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
          const Icon(Icons.info_outline_rounded, size: 18),
          const SizedBox(width: Insets.s),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
