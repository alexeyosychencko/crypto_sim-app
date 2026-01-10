import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_sim/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Welcome screen appears on first launch', (
    WidgetTester tester,
  ) async {
    // Mock SharedPreferences (though we are passing the flag directly)
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MyApp(isFirstLaunch: true)),
    );

    // Verify 'Welcome' text is present
    expect(find.textContaining('Welcome'), findsOneWidget);
  });
}
