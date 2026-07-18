import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_config.dart';

/// Push notifications. Only soft, child-safe messages are ever sent
/// (friend invite, daily gift, new season) — see supabase/migrations notes.
/// Firebase itself never stores app data: it only mints a device token,
/// which is uploaded to Supabase `device_tokens`; the actual send happens
/// server-side from a Supabase Edge Function (supabase/functions/send-push).
abstract class PushService {
  Future<void> init();

  /// Uploads (or removes, when [userId] is null) this device's token so the
  /// Supabase Edge Function can reach it. Safe to call every app start.
  Future<void> syncToken(String? userId);

  Future<void> updateTopics({
    required bool invites,
    required bool daily,
    required bool season,
  });
}

/// Used when Firebase is not configured — the app never depends on push.
class NoopPushService implements PushService {
  const NoopPushService();
  @override
  Future<void> init() async {}
  @override
  Future<void> syncToken(String? userId) async {}
  @override
  Future<void> updateTopics({
    required bool invites,
    required bool daily,
    required bool season,
  }) async {}
}

class FcmPushService implements PushService {
  bool _ready = false;
  String? _token;

  @override
  Future<void> init() async {
    try {
      // Android/iOS read the committed native config files automatically;
      // only web has no such mechanism and needs explicit options.
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: AppConfig.firebaseApiKey,
            appId: AppConfig.firebaseAppId,
            messagingSenderId: AppConfig.firebaseSenderId,
            projectId: AppConfig.firebaseProjectId,
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      final settings = await FirebaseMessaging.instance.requestPermission();
      _ready =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (_ready) {
        _token = await FirebaseMessaging.instance.getToken(
          vapidKey: kIsWeb && AppConfig.firebaseVapidKey != ''
              ? AppConfig.firebaseVapidKey
              : null,
        );
        FirebaseMessaging.instance.onTokenRefresh.listen((t) => _token = t);
      }
    } on FirebaseException {
      _ready = false;
    }
  }

  @override
  Future<void> syncToken(String? userId) async {
    if (!_ready || !AppConfig.isOnline || _token == null) return;
    final client = Supabase.instance.client;
    if (userId == null) {
      await client.from('device_tokens').delete().eq('token', _token!);
      return;
    }
    await client.from('device_tokens').upsert({
      'user_id': userId,
      'token': _token,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    });
  }

  @override
  Future<void> updateTopics({
    required bool invites,
    required bool daily,
    required bool season,
  }) async {
    // Topic subscribe is not supported on web; web tokens are managed
    // server-side (see supabase migration notes).
    if (!_ready || kIsWeb) return;
    final messaging = FirebaseMessaging.instance;
    Future<void> setTopic(String topic, bool on) => on
        ? messaging.subscribeToTopic(topic)
        : messaging.unsubscribeFromTopic(topic);
    await setTopic('daily_gift', daily);
    await setTopic('season', season);
    await setTopic('invites', invites);
  }
}

final pushServiceProvider = Provider<PushService>(
  (ref) => AppConfig.pushReady ? FcmPushService() : const NoopPushService(),
);
