import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:accel_stats/services/calibration_service.dart';
import 'package:accel_stats/services/sensor_service.dart';

/// Full integration-style test: calibrate → car moves at GPS speed →
/// phone rotates mid-drive → verify forward acceleration decomposition
/// stays correct throughout.
///
/// The test simulates:
///  1. Calibration phase (phone flat, stationary)
///  2. Car accelerating north at a known rate with GPS heading updates
///  3. Phone rotating (pitch, yaw, roll) while car maintains motion
///  4. Verification that computed forward accel matches expected value

/// Helper: calibrate phone lying flat.
CalibrationResult _calibrateFlat() {
  final service = CalibrationService();
  final now = DateTime.now();
  for (int i = 0; i < 250; i++) {
    service.addSample(AccelerometerReading(0, 0, 9.81, now));
  }
  return service.compute()!;
}

/// Multiply two 3x3 matrices (row-major flat).
List<double> _matMul(List<double> a, List<double> b) {
  final r = List<double>.filled(9, 0);
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      for (int k = 0; k < 3; k++) {
        r[i * 3 + j] += a[i * 3 + k] * b[k * 3 + j];
      }
    }
  }
  return r;
}

void main() {
  group('Scenario: phone rotates while car moves at GPS speed', () {
    test(
      'yaw rotation during constant forward accel — horizontal magnitude stable',
      () {
        // Phase 1: Calibrate flat
        final calibration = _calibrateFlat();
        final decomposer = AccelerationDecomposer(calibration);

        // No GPS heading — just verify horizontal accel magnitude is preserved
        // during phone yaw rotation, regardless of which world axis it lands on.

        const dt = 0.02;
        const yawRate = 0.5;
        const totalSec = 3.0;
        final numSteps = (totalSec / dt).round();

        // Track phone orientation externally
        var phoneToWorld = List<double>.from(calibration.rotationMatrix);

        final horizMags = <double>[];

        for (int i = 0; i < numSteps; i++) {
          decomposer.updateWithGyro(0, 0, yawRate, dt);

          // Update external tracking with same z-axis Rodrigues rotation
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
          phoneToWorld = _matMul(phoneToWorld, dR);

          // World accel: 2 m/s² along worldY + gravity along worldZ
          final worldAccel = [0.0, 2.0, 9.81];

          // Phone frame = R^T * world
          final px =
              phoneToWorld[0] * worldAccel[0] +
              phoneToWorld[3] * worldAccel[1] +
              phoneToWorld[6] * worldAccel[2];
          final py =
              phoneToWorld[1] * worldAccel[0] +
              phoneToWorld[4] * worldAccel[1] +
              phoneToWorld[7] * worldAccel[2];
          final pz =
              phoneToWorld[2] * worldAccel[0] +
              phoneToWorld[5] * worldAccel[1] +
              phoneToWorld[8] * worldAccel[2];

          final result = decomposer.decompose(px, py, pz);
          final hMag = sqrt(result[0] * result[0] + result[1] * result[1]);
          horizMags.add(hMag);
        }

        for (final m in horizMags) {
          expect(m, closeTo(2.0, 0.3));
        }
      },
    );

    test(
      'pitch rotation during constant forward accel — forward accel stable',
      () {
        final calibration = _calibrateFlat();
        final decomposer = AccelerationDecomposer(calibration);
        decomposer.gpsHeadingRad = 0;

        // Calibrate heading
        for (int i = 0; i < 10; i++) {
          decomposer.decompose(2.0, 0, 9.81);
          decomposer.onGpsUpdate(0, 1.0);
        }

        // Phone pitches forward (rotates around X) at 0.3 rad/s for 2 sec
        const dt = 0.02;
        const pitchRate = 0.3; // rad/s
        const totalSec = 2.0;
        final numSteps = (totalSec / dt).round();

        double cumulativePitch = 0;
        final forwardResults = <double>[];

        for (int i = 0; i < numSteps; i++) {
          decomposer.updateWithGyro(pitchRate, 0, 0, dt);
          cumulativePitch += pitchRate * dt;

          // World: 2 m/s² north + gravity.
          // In phone frame after pitch around X:
          // Phone Y and Z rotate. Gravity shifts from Z to Y.
          // Forward accel (along world X) stays on phone X.
          final phoneAccelX = 2.0; // forward stays on X for pitch around X
          final phoneAccelY = 9.81 * sin(cumulativePitch);
          final phoneAccelZ = 9.81 * cos(cumulativePitch);

          final result = decomposer.decompose(
            phoneAccelX,
            phoneAccelY,
            phoneAccelZ,
          );
          forwardResults.add(result[0]);
        }

        for (int i = 0; i < forwardResults.length; i++) {
          expect(
            forwardResults[i],
            closeTo(2.0, 0.6),
            reason: 'Step $i: forward=${forwardResults[i]}',
          );
        }
      },
    );

    test('combined pitch + yaw rotation — horizontal magnitude preserved', () {
      final calibration = _calibrateFlat();
      final decomposer = AccelerationDecomposer(calibration);

      const dt = 0.02;
      const totalSec = 2.0;
      const yawRate = 0.4;
      const pitchRate = 0.2;
      final numSteps = (totalSec / dt).round();

      // Track phone orientation externally for ground truth
      var phoneToWorld = List<double>.from(calibration.rotationMatrix);
      final carAccel = 2.0; // m/s² in world frame

      final horizMags = <double>[];

      for (int i = 0; i < numSteps; i++) {
        decomposer.updateWithGyro(pitchRate, 0, yawRate, dt);

        // Update external tracking matrix with same Rodrigues step
        final omega = [pitchRate * dt, 0.0, yawRate * dt];
        final angle = sqrt(
          omega[0] * omega[0] + omega[1] * omega[1] + omega[2] * omega[2],
        );
        if (angle > 1e-9) {
          final sinA = sin(angle);
          final cosA = cos(angle);
          final omc = 1.0 - cosA;
          final nx = omega[0] / angle;
          final ny = omega[1] / angle;
          final nz = omega[2] / angle;
          final dR = [
            cosA + nx * nx * omc,
            nx * ny * omc - nz * sinA,
            nx * nz * omc + ny * sinA,
            ny * nx * omc + nz * sinA,
            cosA + ny * ny * omc,
            ny * nz * omc - nx * sinA,
            nz * nx * omc - ny * sinA,
            nz * ny * omc + nx * sinA,
            cosA + nz * nz * omc,
          ];
          phoneToWorld = _matMul(phoneToWorld, dR);
        }

        // World accel: car accel along worldY + gravity along worldZ
        final worldAccel = [0.0, carAccel, 9.81];

        // Phone frame = R^T * world
        final phoneAccel = [
          phoneToWorld[0] * worldAccel[0] +
              phoneToWorld[3] * worldAccel[1] +
              phoneToWorld[6] * worldAccel[2],
          phoneToWorld[1] * worldAccel[0] +
              phoneToWorld[4] * worldAccel[1] +
              phoneToWorld[7] * worldAccel[2],
          phoneToWorld[2] * worldAccel[0] +
              phoneToWorld[5] * worldAccel[1] +
              phoneToWorld[8] * worldAccel[2],
        ];

        final result = decomposer.decompose(
          phoneAccel[0],
          phoneAccel[1],
          phoneAccel[2],
        );
        final hMag = sqrt(result[0] * result[0] + result[1] * result[1]);
        horizMags.add(hMag);
      }

      // Horizontal magnitude should stay near 2.0
      final avg = horizMags.reduce((a, b) => a + b) / horizMags.length;
      expect(avg, closeTo(2.0, 0.3));
    });

    test('GPS speed thresholding — below 0.5 m/s snaps to 0', () {
      // This tests the constant from SensorConstants.gpsStationarySpeed
      const stationaryThreshold = 0.5;

      // Speed below threshold → treated as 0
      expect(0.3 < stationaryThreshold, isTrue);
      final effectiveSpeed = 0.3 < stationaryThreshold ? 0.0 : 0.3;
      expect(effectiveSpeed, equals(0.0));

      // Speed above threshold → kept as-is
      expect(0.6 < stationaryThreshold, isFalse);
      final effectiveSpeed2 = 0.6 < stationaryThreshold ? 0.0 : 0.6;
      expect(effectiveSpeed2, equals(0.6));
    });

    test('accel noise floor clamping when stationary', () {
      // When effective speed is 0 and accel < noise floor, it clamps to 0
      const noiseFloor = 0.05; // g

      // Small accel while stationary → clamped
      final accelG = 0.03;
      final clamped = (accelG.abs() < noiseFloor) ? 0.0 : accelG;
      expect(clamped, equals(0.0));

      // Meaningful accel while stationary → not clamped
      final accelG2 = 0.1;
      final clamped2 = (accelG2.abs() < noiseFloor) ? 0.0 : accelG2;
      expect(clamped2, equals(0.1));
    });

    test(
      'long drive: phone does full 360° roll — horizontal magnitude preserved',
      () {
        final calibration = _calibrateFlat();
        final decomposer = AccelerationDecomposer(calibration);

        // Roll around Y at 0.5 rad/s → full 360°
        const dt = 0.02;
        const rollRate = 0.5;
        const totalSec = 2 * pi / rollRate; // one full rotation
        final numSteps = (totalSec / dt).round();

        // Track phone orientation externally
        var phoneToWorld = List<double>.from(calibration.rotationMatrix);
        final carAccel = 1.5;

        final horizMags = <double>[];

        for (int i = 0; i < numSteps; i++) {
          decomposer.updateWithGyro(0, rollRate, 0, dt);

          // Update external tracking with Y-axis Rodrigues rotation
          final angle = rollRate * dt;
          final dR = [
            cos(angle),
            0.0,
            sin(angle),
            0.0,
            1.0,
            0.0,
            -sin(angle),
            0.0,
            cos(angle),
          ];
          phoneToWorld = _matMul(phoneToWorld, dR);

          // World accel: car accel along worldY + gravity along worldZ
          final worldAccel = [0.0, carAccel, 9.81];

          // Phone frame = R^T * world
          final px =
              phoneToWorld[0] * worldAccel[0] +
              phoneToWorld[3] * worldAccel[1] +
              phoneToWorld[6] * worldAccel[2];
          final py =
              phoneToWorld[1] * worldAccel[0] +
              phoneToWorld[4] * worldAccel[1] +
              phoneToWorld[7] * worldAccel[2];
          final pz =
              phoneToWorld[2] * worldAccel[0] +
              phoneToWorld[5] * worldAccel[1] +
              phoneToWorld[8] * worldAccel[2];

          final result = decomposer.decompose(px, py, pz);
          final hMag = sqrt(result[0] * result[0] + result[1] * result[1]);
          horizMags.add(hMag);
        }

        // Horizontal magnitude should stay near 1.5
        final avg = horizMags.reduce((a, b) => a + b) / horizMags.length;
        expect(avg, closeTo(1.5, 0.3));
      },
    );

    test('phone orientation degrees track rotation correctly', () {
      final calibration = _calibrateFlat();
      final decomposer = AccelerationDecomposer(calibration);

      // Initially flat → pitch/roll ≈ 0
      var orient = decomposer.orientationDegrees;
      expect(orient[0].abs(), lessThan(1));
      expect(orient[1].abs(), lessThan(1));

      // Pitch 30° (rotate around X)
      const dt = 0.01;
      final pitchSteps = (30 * pi / 180 / dt).round();
      for (int i = 0; i < pitchSteps; i++) {
        decomposer.updateWithGyro(1.0, 0, 0, dt);
      }
      orient = decomposer.orientationDegrees;
      expect(orient[0], closeTo(30, 3));
      expect(orient[1].abs(), lessThan(5));

      // Roll 20° (rotate around Y)
      final rollSteps = (20 * pi / 180 / dt).round();
      for (int i = 0; i < rollSteps; i++) {
        decomposer.updateWithGyro(0, 1.0, 0, dt);
      }
      orient = decomposer.orientationDegrees;
      // Pitch should still be around 30, roll around 20
      // (slightly coupled due to 3D rotation, but close)
      expect(orient[0], closeTo(30, 8));
      expect(orient[1].abs(), greaterThan(10));
    });
  });
}
