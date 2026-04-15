import 'package:accel_stats/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders theme and dev mode sections', (tester) async {
      await pumpApp(tester, const SettingsScreen());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Dev Mode'), findsOneWidget);
    });

    testWidgets('theme defaults to System default', (tester) async {
      await pumpApp(tester, const SettingsScreen());

      expect(find.text('System default'), findsOneWidget);
    });

    testWidgets('theme picker opens and allows selection', (tester) async {
      await pumpApp(tester, const SettingsScreen());

      // Tap Theme tile to open picker
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Select Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Dialog should close, subtitle should update
      expect(find.text('Choose Theme'), findsNothing);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('dev mode switch toggles', (tester) async {
      final harness = await pumpApp(tester, const SettingsScreen());

      // Initially off
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      var switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);

      // Toggle on
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);

      // Persisted to prefs
      expect(harness.prefs.getBool('dev_mode'), isTrue);
    });

    testWidgets('dev mode loads saved preference', (tester) async {
      await pumpApp(
        tester,
        const SettingsScreen(),
        prefsData: {'dev_mode': true},
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('theme selection persists to prefs', (tester) async {
      final harness = await pumpApp(tester, const SettingsScreen());

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(harness.prefs.getString('theme_mode'), 'light');
    });
  });
}
