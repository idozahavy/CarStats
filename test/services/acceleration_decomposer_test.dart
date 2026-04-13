import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:accel_stats/services/calibration_service.dart';
import 'package:accel_stats/services/sensor_service.dart';

/// Helper: build a CalibrationResult for phone flat on table (gravity along Z).
CalibrationResult _flatCalibration() {
  final service = CalibrationService();
  final now = DateTime.now();
  for (int i = 0; i < 100; i++) {
    service.addSample(AccelerometerReading(0, 0, 9.81, now));
  }
  return service.compute()!;
}

/// Helper: build a CalibrationResult for phone tilted at given pitch (radians)
/// around X axis (forward tilt). Gravity shifts from Z toward Y.
CalibrationResult _tiltedCalibration(double pitchRad) {
  final service = CalibrationService();
  final now = DateTime.now();
  final g = 9.81;
  final gy = g * sin(pitchRad);
  final gz = g * cos(pitchRad);
  for (int i = 0; i < 100; i++) {
    service.addSample(AccelerometerReading(0, gy, gz, now));
  }
  return service.compute()!;
}

void main() {
  group('AccelerationDecomposer — static decomposition', () {
    test('phone flat, pure gravity → vertical ≈ 0 after subtraction', () {
      final decomposer = AccelerationDecomposer(_flatCalibration());
      final result = decomposer.decompose(0, 0, 9.81);
      // forward, lateral ≈ 0; vertical ≈ 0 (gravity subtracted)
      expect(result[0].abs(), lessThan(0.05));
      expect(result[1].abs(), lessThan(0.05));
      expect(result[2].abs(), lessThan(0.05));
    });

    test(
      'phone flat, forward acceleration along phone X → appears in horizontal',
      () {
        final decomposer = AccelerationDecomposer(_flatCalibration());
        // gravity on Z + 3 m/s² on phone X
        final result = decomposer.decompose(3.0, 0, 9.81);
        final horizontalMag = sqrt(
          result[0] * result[0] + result[1] * result[1],
        );
        expect(horizontalMag, closeTo(3.0, 0.1));
        expect(result[2].abs(), lessThan(0.1)); // no vertical component
      },
    );

    test('phone tilted 30° — gravity still removed correctly', () {
      final pitch = 30 * pi / 180;
      final decomposer = AccelerationDecomposer(_tiltedCalibration(pitch));
      // Pure gravity from tilted phone perspective
      final g = 9.81;
      final result = decomposer.decompose(0, g * sin(pitch), g * cos(pitch));
      // All components should be near 0 (gravity subtracted)
      expect(result[0].abs(), lessThan(0.1));
      expect(result[1].abs(), lessThan(0.1));
      expect(result[2].abs(), lessThan(0.1));
    });
  });

  group('AccelerationDecomposer — gyro integration (phone rotation)', () {
    test(
      'phone rotates 90° around X while stationary — gravity still removed',
      () {
        // Start flat, then simulate 90° rotation around phone X axis (pitch up).
        final decomposer = AccelerationDecomposer(_flatCalibration());

        // Simulate gyro: rotate around X at 1 rad/s for pi/2 seconds
        // Use small steps for numerical accuracy
        const totalAngle = pi / 2;
        const dt = 0.01; // 10ms steps
        final steps = (totalAngle / (1.0 * dt)).round();

        for (int i = 0; i < steps; i++) {
          decomposer.updateWithGyro(1.0, 0, 0, dt);
        }

        // After 90° pitch: gravity now along phone Y axis
        final result = decomposer.decompose(0, 9.81, 0);
        expect(result[0].abs(), lessThan(0.3));
        expect(result[1].abs(), lessThan(0.3));
        expect(result[2].abs(), lessThan(0.3));
      },
    );

    test('phone rotates 90° around Z — horizontal accel still correct', () {
      final decomposer = AccelerationDecomposer(_flatCalibration());

      // Rotate 90° around Z (yaw rotation)
      const dt = 0.01;
      final steps = (pi / 2 / dt).round();
      for (int i = 0; i < steps; i++) {
        decomposer.updateWithGyro(0, 0, 1.0, dt);
      }

      // After 90° yaw: phone X now points where Y used to.
      // Apply 3 m/s² along phone Y (which is now old X direction).
      final result = decomposer.decompose(0, 3.0, 9.81);
      final horizontalMag = sqrt(result[0] * result[0] + result[1] * result[1]);
      expect(horizontalMag, closeTo(3.0, 0.3));
      expect(result[2].abs(), lessThan(0.3));
    });

    test(
      'continuous yaw rotation during acceleration — horizontal magnitude stable',
      () {
        final decomposer = AccelerationDecomposer(_flatCalibration());

        // Simulate phone slowly rotating around Z (yaw) at 0.5 rad/s
        // while there's 2 m/s² horizontal acceleration in world frame.
        // Don't use GPS heading — just verify horizontal magnitude is preserved.
        const dt = 0.02; // 50 Hz
        const totalTime = 2.0; // 2 seconds
        final numSteps = (totalTime / dt).round();

        // Track phone orientation externally to compute correct phone-frame accel
        var phoneToWorld = List<double>.from(_flatCalibration().rotationMatrix);

        final horizMags = <double>[];

        for (int i = 0; i < numSteps; i++) {
          const yawRate = 0.5;
          decomposer.updateWithGyro(0, 0, yawRate, dt);

          // Update external tracking matrix with same Rodrigues step
          final angle = yawRate * dt;
          final dR = [
            cos(angle),
            -sin(angle),
            0.0,
            sin(angle),
            cos(angle),
            0.0,
            0.0,
            0.0,
            1.0,
          ];
          final newR = List<double>.filled(9, 0.0);
          for (int r = 0; r < 3; r++) {
            for (int c = 0; c < 3; c++) {
              for (int k = 0; k < 3; k++) {
                newR[r * 3 + c] += phoneToWorld[r * 3 + k] * dR[k * 3 + c];
              }
            }
          }
          phoneToWorld = newR;

          // World accel: 2 m/s² along worldY + gravity along worldZ
          // Phone accel = R^T * world_accel
          final wx = 0.0, wy = 2.0, wz = 9.81;
          final px =
              phoneToWorld[0] * wx +
              phoneToWorld[3] * wy +
              phoneToWorld[6] * wz;
          final py =
              phoneToWorld[1] * wx +
              phoneToWorld[4] * wy +
              phoneToWorld[7] * wz;
          final pz =
              phoneToWorld[2] * wx +
              phoneToWorld[5] * wy +
              phoneToWorld[8] * wz;

          final result = decomposer.decompose(px, py, pz);
          final hMag = sqrt(result[0] * result[0] + result[1] * result[1]);
          horizMags.add(hMag);
        }

        // Horizontal magnitude should remain close to 2.0 throughout
        for (final m in horizMags) {
          expect(m, closeTo(2.0, 0.3));
        }
      },
    );
  });

  group('AccelerationDecomposer — complementary filter correction', () {
    test('filter corrects drift back toward true gravity', () {
      final decomposer = AccelerationDecomposer(_flatCalibration());

      // Introduce small gyro drift (simulate sensor bias)
      decomposer.updateWithGyro(0.1, 0, 0, 0.5); // 0.05 rad pitch error

      // Now feed pure gravity readings repeatedly (phone is actually flat)
      for (int i = 0; i < 200; i++) {
        decomposer.correctWithAccel(0, 0, 9.81);
      }

      // After many corrections, decomposition of pure gravity should be ≈ 0
      final result = decomposer.decompose(0, 0, 9.81);
      expect(result[0].abs(), lessThan(0.2));
      expect(result[1].abs(), lessThan(0.2));
      expect(result[2].abs(), lessThan(0.2));
    });

    test('filter ignores accel corrections during high dynamic motion', () {
      final decomposer = AccelerationDecomposer(_flatCalibration());

      // Apply a large accel (car + gravity) that deviates far from 9.81 mag
      // mag = sqrt(64 + 96.24) ≈ 12.66, deviation = 2.85 > tolerance of 2.0
      // This should NOT corrupt the gravity estimate.
      for (int i = 0; i < 100; i++) {
        decomposer.correctWithAccel(8.0, 0, 9.81);
      }

      // Gravity should still be well-estimated
      final result = decomposer.decompose(0, 0, 9.81);
      expect(result[2].abs(), lessThan(0.1));
    });
  });

  group('AccelerationDecomposer — orientation degrees', () {
    test('phone flat — pitch and roll ≈ 0', () {
      final decomposer = AccelerationDecomposer(_flatCalibration());
      final orient = decomposer.orientationDegrees;
      expect(orient[0].abs(), lessThan(1)); // pitch
      expect(orient[1].abs(), lessThan(1)); // roll
    });

    test('phone pitched 45° — pitch ≈ 45°', () {
      final decomposer = AccelerationDecomposer(_flatCalibration());
      // Rotate 45° around X (pitch)
      const dt = 0.01;
      final steps = (pi / 4 / dt).round();
      for (int i = 0; i < steps; i++) {
        decomposer.updateWithGyro(1.0, 0, 0, dt);
      }
      final orient = decomposer.orientationDegrees;
      expect(orient[0], closeTo(45, 3)); // pitch
      expect(orient[1].abs(), lessThan(5)); // roll stays near 0
    });
  });
}
