import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/screens/comparison/comparison_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  group('ComparisonScreen', () {
    testWidgets('renders both recording names and chart titles',
        (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Run A', durationMs: 10000),
        fakeRecording(id: 2, name: 'Run B', durationMs: 12000),
      ];
      db.samplesByRecording[1] = _movingSamples(recordingId: 1);
      db.samplesByRecording[2] = _movingSamples(recordingId: 2);

      await pumpApp(
        tester,
        const ComparisonScreen(idA: 1, idB: 2),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(find.text('Compare'), findsOneWidget);
      // Recording names appear in header card and legends — at least once each.
      expect(find.text('Run A'), findsAtLeastNWidgets(1));
      expect(find.text('Run B'), findsAtLeastNWidgets(1));
      expect(find.text('Speed over time'), findsOneWidget);
      expect(find.text('Acceleration over time'), findsOneWidget);
      expect(find.byType(LineChart), findsNWidgets(2));
    });

    testWidgets('alignment shifts both recordings to start at x=0',
        (tester) async {
      // A starts moving at t=2s, B starts moving at t=5s.
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'A starts at 2s', durationMs: 8000),
        fakeRecording(id: 2, name: 'B starts at 5s', durationMs: 10000),
      ];
      db.samplesByRecording[1] = _delayedMovementSamples(
        recordingId: 1,
        moveStartUs: 2 * 1000000,
        endUs: 8 * 1000000,
      );
      db.samplesByRecording[2] = _delayedMovementSamples(
        recordingId: 2,
        moveStartUs: 5 * 1000000,
        endUs: 10 * 1000000,
      );

      await pumpApp(
        tester,
        const ComparisonScreen(idA: 1, idB: 2),
        db: db,
      );
      await tester.pumpAndSettle();

      final lineCharts = tester.widgetList<LineChart>(find.byType(LineChart));
      expect(lineCharts, isNotEmpty);
      for (final chart in lineCharts) {
        expect(chart.data.minX, 0);
        for (final bar in chart.data.lineBarsData) {
          if (bar.spots.isEmpty) continue;
          expect(bar.spots.first.x, 0);
        }
      }
    });

    testWidgets('recording without movement shows warning', (tester) async {
      final db = FakeDatabase();
      db.recordings = [
        fakeRecording(id: 1, name: 'Stationary'),
        fakeRecording(id: 2, name: 'Moving'),
      ];
      db.samplesByRecording[1] = [
        for (var i = 0; i < 10; i++)
          fakeSample(
            id: i + 1,
            recordingId: 1,
            timestampUs: i * 100000,
            gpsSpeed: 0.1, // < 1 km/h
            forwardAccel: 0,
          ),
      ];
      db.samplesByRecording[2] = _movingSamples(recordingId: 2);

      await pumpApp(
        tester,
        const ComparisonScreen(idA: 1, idB: 2),
        db: db,
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Recording Stationary has no movement above 1 km/h.'),
        findsOneWidget,
      );
    });
  });
}

List<SensorSample> _movingSamples({required int recordingId}) {
  return [
    for (var i = 0; i < 200; i++)
      fakeSample(
        id: 1000 * recordingId + i,
        recordingId: recordingId,
        timestampUs: i * 50000,
        // 0 → ~36 km/h linear ramp.
        gpsSpeed: 1 + i * 0.05,
        forwardAccel: 2.0,
      ),
  ];
}

List<SensorSample> _delayedMovementSamples({
  required int recordingId,
  required int moveStartUs,
  required int endUs,
}) {
  const stepUs = 50000;
  final samples = <SensorSample>[];
  var idCounter = 1000 * recordingId;
  for (int t = 0; t < endUs; t += stepUs) {
    samples.add(
      fakeSample(
        id: idCounter++,
        recordingId: recordingId,
        timestampUs: t,
        gpsSpeed: t < moveStartUs ? 0.1 : 5.0,
        forwardAccel: t < moveStartUs ? 0 : 2.0,
      ),
    );
  }
  return samples;
}
