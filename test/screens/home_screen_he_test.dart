import 'package:accel_stats/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('HomeScreen (Hebrew locale)', () {
    testWidgets('renders Hebrew title and buttons', (tester) async {
      await pumpApp(
        tester,
        const HomeScreen(),
        locale: const Locale('he'),
        prefsData: {'locale': 'he'},
      );

      // Hebrew start-recording button
      expect(find.text('התחל הקלטה'), findsOneWidget);
      // Hebrew view-recordings button
      expect(find.text('הצג הקלטות'), findsOneWidget);
    });

    testWidgets('uses RTL directionality', (tester) async {
      await pumpApp(
        tester,
        const HomeScreen(),
        locale: const Locale('he'),
      );

      final dir = Directionality.of(
        tester.element(find.text('התחל הקלטה')),
      );
      expect(dir, TextDirection.rtl);
    });
  });
}
