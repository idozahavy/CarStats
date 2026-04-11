import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:car_stats/services/calibration_service.dart';
import 'package:car_stats/services/sensor_service.dart';

void main() {
  group('CalibrationService', () {
    late CalibrationService service;

    setUp(() {
      service = CalibrationService();
    });

    test('phone flat on table — gravity along Z', () {
      // Simulate phone lying flat: accel ≈ (0, 0, 9.81)
      final now = DateTime.now();
      for (int i = 0; i < 100; i++) {
        service.addSample(AccelerometerReading(0, 0, 9.81, now));
      }

      final result = service.compute();
      expect(result, isNotNull);

      // Gravity vector should point along Z: [0, 0, 1]
      expect(result!.gravityVector[0], closeTo(0, 0.01));
      expect(result.gravityVector[1], closeTo(0, 0.01));
      expect(result.gravityVector[2], closeTo(1, 0.01));
    });

    test('phone upright — gravity along Y', () {
      final now = DateTime.now();
      for (int i = 0; i < 100; i++) {
        service.addSample(AccelerometerReading(0, 9.81, 0, now));
      }

      final result = service.compute();
      expect(result, isNotNull);
      expect(result!.gravityVector[0], closeTo(0, 0.01));
      expect(result.gravityVector[1], closeTo(1, 0.01));
      expect(result.gravityVector[2], closeTo(0, 0.01));
    });

    test('phone tilted 45° forward — gravity between Y and Z', () {
      final now = DateTime.now();
      final g = 9.81;
      final component = g * sin(pi / 4); // ~6.94
      for (int i = 0; i < 100; i++) {
        service.addSample(AccelerometerReading(0, component, component, now));
      }

      final result = service.compute();
      expect(result, isNotNull);
      final expected = sin(pi / 4);
      expect(result!.gravityVector[1], closeTo(expected, 0.01));
      expect(result.gravityVector[2], closeTo(expected, 0.01));
    });

    test('rotation matrix is orthogonal', () {
      final now = DateTime.now();
      for (int i = 0; i < 100; i++) {
        service.addSample(AccelerometerReading(2.0, 3.0, 8.5, now));
      }

      final result = service.compute()!;
      final r = result.rotationMatrix;

      // Check rows are unit vectors
      for (int row = 0; row < 3; row++) {
        final mag = sqrt(
          r[row * 3] * r[row * 3] +
              r[row * 3 + 1] * r[row * 3 + 1] +
              r[row * 3 + 2] * r[row * 3 + 2],
        );
        expect(mag, closeTo(1.0, 1e-6));
      }

      // Check rows are orthogonal (dot products ≈ 0)
      for (int i = 0; i < 3; i++) {
        for (int j = i + 1; j < 3; j++) {
          final dot =
              r[i * 3] * r[j * 3] +
              r[i * 3 + 1] * r[j * 3 + 1] +
              r[i * 3 + 2] * r[j * 3 + 2];
          expect(dot, closeTo(0, 1e-6));
        }
      }
    });

    test('no samples returns null', () {
      expect(service.compute(), isNull);
    });

    test('reset clears samples', () {
      final now = DateTime.now();
      service.addSample(AccelerometerReading(0, 0, 9.81, now));
      expect(service.sampleCount, 1);
      service.reset();
      expect(service.sampleCount, 0);
      expect(service.compute(), isNull);
    });
  });
}
