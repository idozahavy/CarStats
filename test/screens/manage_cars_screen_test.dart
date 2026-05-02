import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/screens/manage_cars/manage_cars_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  group('ManageCarsScreen', () {
    testWidgets('shows empty state with no cars', (tester) async {
      await pumpApp(tester, const ManageCarsScreen());
      await tester.pumpAndSettle();

      expect(find.text('No cars yet'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
      expect(find.text('Add car'), findsOneWidget);
    });

    testWidgets('FAB opens form, adding a car renders the row',
        (tester) async {
      final db = FakeDatabase();
      await pumpApp(tester, const ManageCarsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add car'));
      await tester.pumpAndSettle();

      expect(find.text('New car'), findsOneWidget);

      // The Name field is the first text field in the dialog form.
      await tester.enterText(
        find.byType(TextFormField).first,
        'Daily Driver',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Daily Driver'), findsOneWidget);
      expect(db.carProfiles, hasLength(1));
      expect(db.carProfiles.single.name, 'Daily Driver');
    });

    testWidgets('preloaded cars render as list rows', (tester) async {
      final db = FakeDatabase();
      await db.insertCarProfile(
        CarProfilesCompanion.insert(
          name: 'Track Car',
          make: const Value('Honda'),
          model: const Value('Civic'),
        ),
      );
      await pumpApp(tester, const ManageCarsScreen(), db: db);
      await tester.pumpAndSettle();

      expect(find.text('Track Car'), findsOneWidget);
      expect(find.textContaining('Honda'), findsOneWidget);
    });
  });
}
