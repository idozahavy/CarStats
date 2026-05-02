import 'package:accel_stats/screens/recordings/recordings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  group('RecordingsScreen', () {
    testWidgets('shows empty state with CTA when no recordings',
        (tester) async {
      await pumpApp(tester, const RecordingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('No recordings yet'), findsOneWidget);
      expect(find.text('Start a recording'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('shows filtered-empty state when filter hides everything',
        (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'User Run', isDevRecording: false),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dev'));
      await tester.pump();

      expect(find.text('No recordings match this filter.'), findsOneWidget);
      // CTA should not appear in the filtered-empty case
      expect(find.text('Start a recording'), findsNothing);
    });

    testWidgets('lists recordings from database', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Morning Run', durationMs: 60000),
        fakeRecording(
          id: 2,
          name: 'Track Day',
          durationMs: 120000,
          isDevRecording: true,
        ),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Track Day'), findsOneWidget);
    });

    testWidgets('filter chips show All, User, Dev', (tester) async {
      await pumpApp(tester, const RecordingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Dev'), findsOneWidget);
    });

    testWidgets('User filter hides dev recordings', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'User Run', isDevRecording: false),
        fakeRecording(id: 2, name: 'Dev Run', isDevRecording: true),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      // Both visible initially
      expect(find.text('User Run'), findsOneWidget);
      expect(find.text('Dev Run'), findsOneWidget);

      // Tap User filter
      await tester.tap(find.text('User'));
      await tester.pump();

      expect(find.text('User Run'), findsOneWidget);
      expect(find.text('Dev Run'), findsNothing);
    });

    testWidgets('Dev filter hides user recordings', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'User Run', isDevRecording: false),
        fakeRecording(id: 2, name: 'Dev Run', isDevRecording: true),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dev'));
      await tester.pump();

      expect(find.text('User Run'), findsNothing);
      expect(find.text('Dev Run'), findsOneWidget);
    });

    testWidgets('delete shows confirmation dialog', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'To Delete'),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      // Tap the delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Recording'), findsOneWidget);
      expect(find.text('Delete "To Delete"? This cannot be undone.'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('confirming delete removes the recording', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Gone Soon'),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(db.deletedRecordingIds, contains(1));
      expect(find.text('Gone Soon'), findsNothing);
    });

    testWidgets('cancelling delete keeps the recording', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Still Here'),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(db.deletedRecordingIds, isEmpty);
      expect(find.text('Still Here'), findsOneWidget);
    });

    testWidgets('displays duration and date for recordings', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(
          id: 1,
          name: 'Timed Run',
          startedAt: DateTime(2025, 3, 15, 14, 30),
          durationMs: 90000, // 1m 30s
        ),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      expect(find.textContaining('1m 30s'), findsOneWidget);
      expect(find.textContaining('Mar 15, 2025'), findsOneWidget);
    });

    testWidgets('dev recordings show science icon', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Dev Test', isDevRecording: true),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.science), findsOneWidget);
    });

    testWidgets('user recordings show route icon', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Road Trip', isDevRecording: false),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.route), findsOneWidget);
    });

    testWidgets('long-press opens rename dialog and renames recording',
        (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Old Name'),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Old Name'));
      await tester.pumpAndSettle();

      expect(find.text('Rename recording'), findsOneWidget);
      expect(find.text('Rename'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'New Name');
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();

      expect(db.renamedRecordings, hasLength(1));
      expect(db.renamedRecordings.first.id, 1);
      expect(db.renamedRecordings.first.name, 'New Name');
      expect(find.text('New Name'), findsOneWidget);
    });

    testWidgets('cancelling rename does not call renameRecording',
        (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Untouched'),
      ];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Untouched'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(db.renamedRecordings, isEmpty);
      expect(find.text('Untouched'), findsOneWidget);
    });

    testWidgets('tapping a recording navigates to detail screen',
        (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Detail Target'),
      ];
      db.samplesByRecording[1] = [];

      await pumpApp(tester, const RecordingsScreen(), db: db);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Detail Target'));
      await tester.pumpAndSettle();

      // Should navigate to recording detail screen
      expect(find.text('Detail Target'), findsOneWidget);
    });
  });
}
