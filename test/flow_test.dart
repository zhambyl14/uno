import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_family/app/app.dart';
import 'package:uno_family/core/constants/strings.dart';
import 'package:uno_family/core/services/prefs_service.dart';
import 'package:uno_family/core/services/push_service.dart';

Future<void> _boot(WidgetTester tester) async {
  // A generous surface so modal sheets and lists have room in the harness.
  await tester.binding.setSurfaceSize(const Size(1000, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
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
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('guest lands on home directly and tabs navigate', (tester) async {
    await _boot(tester);

    // No login gate: home is already showing with the mode picker.
    expect(find.text(S.chooseMode), findsOneWidget);

    // Navigate the shell tabs.
    await tester.tap(find.text(S.navShop).last);
    await tester.pumpAndSettle();
    expect(find.text(S.shopSubtitle), findsOneWidget);

    await tester.tap(find.text(S.navFriends).last);
    await tester.pumpAndSettle();
    expect(find.text(S.yourFriendCode), findsOneWidget);

    await tester.tap(find.text(S.navProfile).last);
    await tester.pumpAndSettle();
    expect(find.text(S.statsTitle), findsOneWidget);
    // Guests see an upgrade banner prompting them to sign in.
    expect(find.text(S.guestProfileBannerTitle), findsOneWidget);
  });

  testWidgets('guest tapping a locked mode sees a sign-in gate', (
    tester,
  ) async {
    await _boot(tester);

    await tester.tap(find.text('Family'));
    await tester.pumpAndSettle();

    expect(find.text(S.guestGateTitle), findsOneWidget);

    await tester.tap(find.text(S.signInNow));
    await tester.pumpAndSettle();

    expect(find.text(S.loginTitle), findsOneWidget);
  });
}
