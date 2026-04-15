import 'package:accel_stats/screens/recordings/recordings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  group('RecordingsScreen', () {
    testWidgets('shows empty state when no recordings', (tester) async {
      await pumpApp(tester, const RecordingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('No recordings yet'), findsOneWidget);
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
