import 'package:accel_stats/screens/recording_detail/recording_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  group('RecordingDetailScreen', () {
    testWidgets('shows loading then recording name', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Highway Test', durationMs: 45000),
      ];
      db.samplesByRecording[1] = [];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Highway Test'), findsOneWidget);
    });

    testWidgets('shows empty state when no samples', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Empty Run'),
      ];
      db.samplesByRecording[1] = [];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('No data recorded'), findsOneWidget);
    });

    testWidgets('shows summary cards with sample data', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Data Run', durationMs: 30000),
      ];
      db.samplesByRecording[1] = [
        fakeSample(
          id: 1,
          recordingId: 1,
          timestampUs: 0,
          gpsSpeed: 10.0, // 36 km/h
          forwardAccel: 4.905, // 0.5g
        ),
        fakeSample(
          id: 2,
          recordingId: 1,
          timestampUs: 1000000,
          gpsSpeed: 25.0, // 90 km/h
          forwardAccel: -2.943, // -0.3g braking
        ),
      ];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Max Speed'), findsOneWidget);
      expect(find.text('Max Accel'), findsOneWidget);
      expect(find.text('Max Brake'), findsOneWidget);

      // 25 m/s * 3.6 = 90.0 km/h
      expect(find.text('90.0 km/h'), findsOneWidget);
    });

    testWidgets('shows chart titles', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Chart Run', durationMs: 10000),
      ];
      db.samplesByRecording[1] = [
        fakeSample(
          id: 1,
          recordingId: 1,
          timestampUs: 0,
          gpsSpeed: 10.0,
          forwardAccel: 3.0,
        ),
        fakeSample(
          id: 2,
          recordingId: 1,
          timestampUs: 5000000,
          gpsSpeed: 20.0,
          forwardAccel: 1.0,
        ),
      ];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('Speed vs Acceleration'), findsOneWidget);
      expect(find.text('Acceleration over Time'), findsOneWidget);
      expect(find.text('Speed over Time'), findsOneWidget);
    });

    testWidgets('export menu appears when samples exist', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Export Test'),
      ];
      db.samplesByRecording[1] = [
        fakeSample(id: 1, recordingId: 1, timestampUs: 0),
      ];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      // Export button should be present
      expect(find.byIcon(Icons.file_download), findsOneWidget);

      // Tap to open menu
      await tester.tap(find.byIcon(Icons.file_download));
      await tester.pumpAndSettle();

      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as JSON'), findsOneWidget);
    });

    testWidgets('no export button when no samples', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Empty'),
      ];
      db.samplesByRecording[1] = [];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.file_download), findsNothing);
    });
  });
}
