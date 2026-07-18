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
  testWidgets('guest sign-in reaches home and tabs navigate', (tester) async {
    await _boot(tester);

    // Open the guest profile sheet.
    await tester.tap(find.text(S.playAsGuest));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Aibek');
    await tester.tap(find.text(S.startPlaying));
    await tester.pumpAndSettle();

    // Home greeting proves auth + redirect worked.
    expect(find.text(S.greeting('Aibek')), findsOneWidget);
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
  });
}
