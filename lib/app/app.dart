import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/strings.dart';
import '../core/services/game_sounds.dart';
import '../core/services/haptics.dart';
import '../features/settings/presentation/locale_controller.dart';
import '../features/settings/presentation/settings_controller.dart';
import 'router.dart';
import 'theme.dart';

class UnoFamilyApp extends ConsumerWidget {
  const UnoFamilyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(
      settingsControllerProvider.select((s) => s.themeMode),
    );
    // Keep tactile/sound feedback in sync with the "Sound & vibration" setting.
    final soundOn = ref.watch(
      settingsControllerProvider.select((s) => s.soundOn),
    );
    GameHaptics.enabled = soundOn;
    GameSounds.enabled = soundOn;
    // `S.locale` (read by every S.xxx getter) is synced as a side effect of
    // building LocaleController. Keying the current page by locale forces a
    // full remount on language switch, so every screen re-reads fresh text
    // without every screen needing to watch this provider itself.
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          KeyedSubtree(key: ValueKey(locale), child: child!),
    );
  }
}
