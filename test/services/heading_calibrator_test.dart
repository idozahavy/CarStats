import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:car_stats/services/calibration_service.dart';

void main() {
  group('HeadingCalibrator', () {
    late HeadingCalibrator calibrator;

    setUp(() {
      calibrator = HeadingCalibrator();
    });

    test('not calibrated initially', () {
      expect(calibrator.isCalibrated, isFalse);
      expect(calibrator.offset, isNull);
    });

    test('ignores low horizontal accel', () {
      // Accel magnitude below 1.0 threshold
      calibrator.addSample(wx: 0.3, wy: 0.3, gpsHeadingRad: 0, speedDelta: 2.0);
      expect(calibrator.isCalibrated, isFalse);
    });

    test('ignores small speed changes', () {
      // Speed delta below 0.3 threshold
      calibrator.addSample(wx: 3.0, wy: 0, gpsHeadingRad: 0, speedDelta: 0.1);
      expect(calibrator.isCalibrated, isFalse);
    });

    test('calibrates after 8 consistent samples', () {
      // Simulate accelerating north (heading=0) with accel along worldX
      // offset should be ≈ 0 (worldX already aligned with north)
      for (int i = 0; i < 8; i++) {
        calibrator.addSample(wx: 3.0, wy: 0, gpsHeadingRad: 0, speedDelta: 1.0);
      }
      expect(calibrator.isCalibrated, isTrue);
      expect(calibrator.offset, closeTo(0, 0.2));
    });

    test('detects 90° offset — worldX is 90° from north', () {
      // Accel along worldX but GPS heading is pi/2 (east)
      // → offset should be pi/2
      for (int i = 0; i < 8; i++) {
        calibrator.addSample(
          wx: 3.0,
          wy: 0,
          gpsHeadingRad: pi / 2,
          speedDelta: 1.0,
        );
      }
      expect(calibrator.isCalibrated, isTrue);
      expect(calibrator.offset, closeTo(pi / 2, 0.2));
    });

    test('braking flips accel direction correctly', () {
      // Braking: accel points backward (negative speedDelta),
      // so the calibrator should flip the accel angle by π.
      // Car heading north, braking → accel along -worldX → angle = π
      // After flip → angle = 0, consistent with heading 0.
      for (int i = 0; i < 8; i++) {
        calibrator.addSample(
          wx: -3.0,
          wy: 0,
          gpsHeadingRad: 0,
          speedDelta: -1.0,
        );
      }
      expect(calibrator.isCalibrated, isTrue);
      expect(calibrator.offset, closeTo(0, 0.2));
    });

    test('EMA refines after initial lock', () {
      // Lock with offset ≈ 0
      for (int i = 0; i < 8; i++) {
        calibrator.addSample(wx: 3.0, wy: 0, gpsHeadingRad: 0, speedDelta: 1.0);
      }
      final initialOffset = calibrator.offset!;

      // Send samples with slight heading shift (simulating error correction)
      for (int i = 0; i < 50; i++) {
        calibrator.addSample(
          wx: 3.0,
          wy: 0,
          gpsHeadingRad: 0.1, // slight shift
          speedDelta: 1.0,
        );
      }

      // Offset should have drifted slightly toward 0.1 via EMA
      expect(calibrator.offset!, greaterThan(initialOffset));
      expect(calibrator.offset!, lessThan(0.15));
    });
  });
}
