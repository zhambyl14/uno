import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_family/app/app.dart';
import 'package:uno_family/core/constants/strings.dart';
import 'package:uno_family/core/services/online_mode.dart';
import 'package:uno_family/core/services/prefs_service.dart';
import 'package:uno_family/core/services/push_service.dart';

void main() {
  testWidgets('boots straight into a guest home session (no login gate)', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsServiceProvider.overrideWithValue(PrefsService(prefs)),
          pushServiceProvider.overrideWithValue(const NoopPushService()),
          // Force fully-local repositories: the harness never reaches Supabase.
          isOnlineProvider.overrideWith(() => FixedOnlineMode(false)),
        ],
        child: const UnoFamilyApp(),
      ),
    );

    // Splash → an anonymous guest profile is auto-created → Home.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text(S.chooseMode), findsOneWidget);
    expect(find.text(S.playNow), findsOneWidget);
  });
}
