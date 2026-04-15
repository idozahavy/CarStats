import 'package:accel_stats/screens/home/home_screen.dart';
import 'package:accel_stats/services/recording_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders title and both action buttons', (tester) async {
      await pumpApp(tester, const HomeScreen());

      expect(find.text('AccelStats'), findsOneWidget);
      expect(find.text('Start Recording'), findsOneWidget);
      expect(find.text('View Recordings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('Start Recording transitions engine to calibrating',
        (tester) async {
      final harness = await pumpApp(tester, const HomeScreen());

      await tester.tap(find.text('Start Recording'));
      await tester.pump();
      await tester.pump();

      expect(harness.engine.state, RecordingState.calibrating);

      await harness.engine.stopRecording();
    });

    testWidgets('View Recordings navigates to recordings screen',
        (tester) async {
      await pumpApp(tester, const HomeScreen());

      await tester.tap(find.text('View Recordings'));
      await tester.pumpAndSettle();

      expect(find.text('Recordings'), findsOneWidget);
    });

    testWidgets('settings icon navigates to settings screen', (tester) async {
      await pumpApp(tester, const HomeScreen());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows instruction text', (tester) async {
      await pumpApp(tester, const HomeScreen());

      expect(
        find.textContaining('Mount your phone anywhere'),
        findsOneWidget,
      );
      expect(
        find.textContaining('auto-calibrates'),
        findsOneWidget,
      );
    });

    testWidgets('recording uses dev mode from settings', (tester) async {
      final harness = await pumpApp(
        tester,
        const HomeScreen(),
        prefsData: {'dev_mode': true},
      );

      await tester.tap(find.text('Start Recording'));
      await tester.pump();
      await tester.pump();

      // Finish calibration and check the DB entry
      harness.sensorService.emitAccel(0, 0, 9.81, DateTime.now());
      await harness.engine.finishCalibrationNow();
      await tester.pump();

      expect(harness.db.insertedRecordings, hasLength(1));
      expect(harness.db.insertedRecordings.first.isDevRecording.value, isTrue);

      await harness.engine.stopRecording();
    });
  });
}
