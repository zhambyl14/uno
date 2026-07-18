import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/services/prefs_service.dart';

/// Drives the whole app's language. `S.locale` is what every `S.xxx`
/// getter reads; watching this provider from the app root is what makes
/// switching language rebuild every screen with the new text.
class LocaleController extends Notifier<AppLocale> {
  static const _key = 'locale';

  @override
  AppLocale build() {
    final saved = ref.watch(prefsServiceProvider).getString(_key);
    final locale = AppLocale.fromCode(saved);
    S.locale = locale;
    return locale;
  }

  Future<void> setLocale(AppLocale locale) async {
    S.locale = locale;
    state = locale;
    await ref.read(prefsServiceProvider).setString(_key, locale.code);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, AppLocale>(
  LocaleController.new,
);
