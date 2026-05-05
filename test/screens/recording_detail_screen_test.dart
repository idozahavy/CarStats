import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/screens/recording_detail/recording_detail_screen.dart';
import 'package:drift/drift.dart' show Value;
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

      expect(find.text('Save as CSV'), findsOneWidget);
      expect(find.text('Save as JSON'), findsOneWidget);
      expect(find.text('Share as CSV'), findsOneWidget);
      expect(find.text('Share as JSON'), findsOneWidget);
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

    testWidgets('shows Add details button when no metadata', (tester) async {
      final db = FakeDatabase();
      db.recordings = [fakeRecording(id: 1, name: 'No meta run')];
      db.samplesByRecording[1] = [
        fakeSample(id: 1, recordingId: 1, timestampUs: 0, gpsSpeed: 5.0),
      ];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('Add details'), findsOneWidget);
      expect(find.text('Edit details'), findsNothing);
    });

    testWidgets('shows data quality badge when samples exist', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Quality Run', durationMs: 30000),
      ];
      db.samplesByRecording[1] = [
        for (var i = 0; i < 1500; i++)
          fakeSample(
            id: i + 1,
            recordingId: 1,
            timestampUs: i * 20000,
            gpsSpeed: 10.0,
            forwardAccel: 1.0,
          ),
      ];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('Data quality'), findsOneWidget);
      expect(find.textContaining('Sample rate'), findsOneWidget);
      expect(find.textContaining('GPS coverage'), findsOneWidget);
      expect(find.textContaining('Heading lock'), findsOneWidget);
      expect(find.textContaining('50 Hz'), findsOneWidget);
      expect(find.textContaining('100%'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows benchmarks section with sample data', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Bench Run', durationMs: 6000),
      ];
      db.samplesByRecording[1] = [
        for (var i = 0; i <= 250; i++)
          fakeSample(
            id: i + 1,
            recordingId: 1,
            timestampUs: i * 20000,
            // 0 → 100 km/h linear ramp in 5 s.
            gpsSpeed: 5.5556 * (i * 20000 / 1e6),
            forwardAccel: 5.5556,
          ),
      ];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('Benchmarks'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Max Accel at Speed'), findsOneWidget);
      expect(find.text('Sudden Acceleration'), findsOneWidget);
      expect(find.text('0–100 km/h'), findsOneWidget);
      // Dev banner should NOT appear for a user recording.
      expect(
        find.text('Dev recording — benchmark results may be unreliable.'),
        findsNothing,
      );
    });

    testWidgets('shows dev recording banner', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(
          id: 1,
          name: 'Dev Run',
          durationMs: 5000,
          isDevRecording: true,
        ),
      ];
      db.samplesByRecording[1] = [
        fakeSample(
          id: 1,
          recordingId: 1,
          timestampUs: 0,
          gpsSpeed: 5.0,
          forwardAccel: 1.0,
        ),
      ];

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Dev recording — benchmark results may be unreliable.'),
        findsOneWidget,
      );
    });

    testWidgets('shows metadata summary card when metadata exists',
        (tester) async {
      final db = FakeDatabase();
      db.recordings = [fakeRecording(id: 1, name: 'With meta')];
      db.samplesByRecording[1] = [
        fakeSample(id: 1, recordingId: 1, timestampUs: 0, gpsSpeed: 5.0),
      ];
      final carId = await db.insertCarProfile(
        CarProfilesCompanion.insert(name: 'Daily'),
      );
      await db.upsertMetadata(
        RecordingMetadataCompanion.insert(
          recordingId: 1,
          carProfileId: Value(carId),
          driveMode: const Value('sport'),
          passengerCount: const Value(2),
        ),
      );

      await pumpApp(
        tester,
        const RecordingDetailScreen(recordingId: 1),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit details'), findsOneWidget);
      expect(find.text('Add details'), findsNothing);
      expect(find.textContaining('Daily'), findsOneWidget);
      expect(find.textContaining('sport'), findsOneWidget);
    });
  });
}
