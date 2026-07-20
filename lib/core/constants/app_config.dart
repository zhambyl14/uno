import 'package:flutter/foundation.dart' show kIsWeb;

/// Build-time configuration via --dart-define.
///
/// Without Supabase keys the app runs fully in local mode (bots, local
/// profile). With keys it becomes a realtime online game. Push works two
/// ways: Android/iOS read the committed native config files
/// (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`)
/// automatically — no dart-define needed. Web has no native config
/// mechanism, so it needs the FIREBASE_* defines below (see README).
abstract final class AppConfig {
  /// The project is wired online by default: a plain `flutter run` / release
  /// build is a ready-to-play online game (guest auto-login, friends, rooms,
  /// realtime). The publishable/anon key is safe to ship — it only grants
  /// what Row-Level Security allows. Override with `--dart-define` to point at
  /// a different project, or pass empty values to force local-only mode.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qkrwrbeostnosimuqiii.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_YIYmHuzo1jjmJ1T0vC2PXw_Ppu-lULq',
  );

  /// True when the app is built with a real Supabase project.
  static const bool isOnline = supabaseUrl != '' && supabaseAnonKey != '';

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
  );
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String firebaseSenderId = String.fromEnvironment(
    'FIREBASE_SENDER_ID',
  );
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const String firebaseVapidKey = String.fromEnvironment(
    'FIREBASE_VAPID_KEY',
  );

  /// True when a Firebase config is available: native files on
  /// Android/iOS (always — they're committed to the repo), dart-define
  /// values on web (only when explicitly passed).
  static const bool webFirebaseConfigured =
      firebaseApiKey != '' &&
      firebaseAppId != '' &&
      firebaseSenderId != '' &&
      firebaseProjectId != '';
  static const bool pushReady = kIsWeb ? webFirebaseConfigured : true;
}
