import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_family/core/constants/strings.dart';
import 'package:uno_family/features/auth/presentation/widgets/profile_setup_form.dart';

void main() {
  Widget host(void Function(String, String, bool) onSubmit) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ProfileSetupForm(
          submitLabel: S.startPlaying,
          onSubmit: onSubmit,
        ),
      ),
    ),
  );

  testWidgets('child-safe signup rejects a banned nickname', (tester) async {
    var submitted = false;
    await tester.pumpWidget(host((_, _, _) => submitted = true));

    await tester.enterText(find.byType(TextFormField), 'sexyboy');
    await tester.tap(find.text(S.startPlaying));
    await tester.pumpAndSettle();

    expect(submitted, isFalse);
    expect(find.text(S.nickBanned), findsOneWidget);
  });

  testWidgets('valid nickname submits with child flag for young age', (
    tester,
  ) async {
    String? nickname;
    var isChild = false;
    await tester.pumpWidget(
      host((n, _, child) {
        nickname = n;
        isChild = child;
      }),
    );

    await tester.enterText(find.byType(TextFormField), 'magzhan');
    await tester.tap(find.text(S.startPlaying));
    await tester.pumpAndSettle();

    expect(nickname, 'magzhan');
    // Default birth year is 10 years old → child mode on.
    expect(isChild, isTrue);
  });
}
