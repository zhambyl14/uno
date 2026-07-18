import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/constants/app_config.dart';
import 'core/services/prefs_service.dart';
import 'core/services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();

  if (AppConfig.isOnline) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      // Accepts a legacy anon key or a new publishable key.
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  final push = AppConfig.pushReady ? FcmPushService() : const NoopPushService();
  // Push init must never block or crash app startup.
  unawaited(push.init());

  runApp(
    ProviderScope(
      overrides: [
        prefsServiceProvider.overrideWithValue(PrefsService(prefs)),
        pushServiceProvider.overrideWithValue(push),
      ],
      child: const UnoFamilyApp(),
    ),
  );
}
