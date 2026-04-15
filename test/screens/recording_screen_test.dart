import 'package:accel_stats/screens/recording/recording_screen.dart';
import 'package:accel_stats/services/recording_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Starts recording, immediately finishes calibration, pumps once.
Future<DateTime> _enterRecording(
  WidgetTester tester,
  TestHarness harness,
) async {
  final start = DateTime.now();
  await harness.engine.startRecording(name: 'Test', isDev: false);
  harness.sensorService.emitAccel(0, 0, 9.81, start);
  await harness.engine.finishCalibrationNow();
  await tester.pump();
  return start;
}

void main() {
  group('RecordingScreen', () {
    testWidgets('shows live stats after calibration', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      await _enterRecording(tester, harness);

      expect(find.text('Recording'), findsOneWidget);
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Acceleration'), findsOneWidget);
      expect(find.text('Pitch'), findsOneWidget);
      expect(find.text('Roll'), findsOneWidget);
      expect(find.text('Stop Recording'), findsOneWidget);

      await harness.engine.stopRecording();
    });

    testWidgets('speed updates when GPS data arrives', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      final start = await _enterRecording(tester, harness);

      harness.gpsService.emit(
        speed: 20.0,
        heading: 0,
        timestamp: start.add(const Duration(milliseconds: 100)),
      );
      harness.sensorService.emitAccel(
        0, 0, 9.81,
        start.add(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      expect(find.text('72.0'), findsOneWidget);
      expect(find.text('km/h'), findsWidgets);

      await harness.engine.stopRecording();
    });

    testWidgets('stop button transitions to stopped view', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      await _enterRecording(tester, harness);

      await tester.tap(find.text('Stop Recording'));
      await tester.pumpAndSettle();

      expect(find.text('Recording Saved'), findsOneWidget);
      expect(find.text('Recording saved!'), findsOneWidget);
      expect(find.text('View Recording'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('close button resets engine to idle', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      await _enterRecording(tester, harness);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(harness.engine.state, RecordingState.idle);
    });

    testWidgets('peak G labels are displayed', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      await _enterRecording(tester, harness);

      expect(find.text('Peak Accel'), findsOneWidget);
      expect(find.text('Peak Brake'), findsOneWidget);
      expect(find.text('Peak Lateral'), findsOneWidget);

      await harness.engine.stopRecording();
    });

    testWidgets('heading calibration status shows uncalibrated', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      await _enterRecording(tester, harness);

      expect(find.text('Calibrating heading...'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);

      await harness.engine.stopRecording();
    });

    testWidgets('chart shows GPS waiting message without data', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      await _enterRecording(tester, harness);

      expect(find.text('Waiting for GPS data...'), findsOneWidget);

      await harness.engine.stopRecording();
    });

    testWidgets('stopped view shows check icon', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      await _enterRecording(tester, harness);

      await harness.engine.stopRecording();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Recording saved!'), findsOneWidget);
    });

    testWidgets('speed shows dashes when no GPS', (tester) async {
      final harness = await pumpApp(tester, const RecordingScreen());
      final start = await _enterRecording(tester, harness);

      harness.sensorService.emitAccel(
        0, 0, 9.81,
        start.add(const Duration(milliseconds: 50)),
      );
      await tester.pump();

      expect(find.text('--'), findsWidgets);

      await harness.engine.stopRecording();
    });
  });
}
