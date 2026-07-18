import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_family/app/app.dart';
import 'package:uno_family/core/constants/strings.dart';
import 'package:uno_family/core/services/prefs_service.dart';
import 'package:uno_family/core/services/push_service.dart';

void main() {
  testWidgets('boots and lands on the login gate when signed out', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsServiceProvider.overrideWithValue(PrefsService(prefs)),
          pushServiceProvider.overrideWithValue(const NoopPushService()),
        ],
        child: const UnoFamilyApp(),
      ),
    );

    // Splash → auth resolves (no profile) → login.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text(S.loginTitle), findsOneWidget);
    expect(find.text(S.playAsGuest), findsOneWidget);
  });
}
