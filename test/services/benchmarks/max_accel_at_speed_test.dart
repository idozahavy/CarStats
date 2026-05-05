import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/services/benchmarks/benchmarks.dart';
import 'package:accel_stats/services/benchmarks/max_accel_at_speed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  group('computeMaxAccelAtSpeed', () {
    test('returns one entry per defined bucket', () {
      final result = computeMaxAccelAtSpeed(const []);
      expect(result.length, kMaxAccelSpeedBucketsKmh.length);
      for (final r in result) {
        expect(r.peakG, isNull);
      }
    });

    test('peak forward accel near 60 km/h lands in the 60 bucket', () {
      // Single peak of 0.6 g (5.886 m/s²) at exactly 60 km/h.
      final samples = <SensorSample>[
        for (var i = 0; i < 50; i++)
          fakeSample(
            id: i,
            timestampUs: i * 20000,
            gpsSpeed: 60 / 3.6, // 60 km/h
            forwardAccel: 5.886, // 0.6 g
          ),
        for (var i = 50; i < 100; i++)
          fakeSample(
            id: i,
            timestampUs: i * 20000,
            gpsSpeed: 30 / 3.6, // 30 km/h
            forwardAccel: 1.0, // ~0.1 g
          ),
      ];
      final result = computeMaxAccelAtSpeed(samples);
      final b60 = result.firstWhere((b) => b.speedBucketKmh == 60);
      expect(b60.peakG, closeTo(0.6, 0.01));

      // 100 km/h bucket should be empty (no samples there).
      final b100 = result.firstWhere((b) => b.speedBucketKmh == 100);
      expect(b100.peakG, isNull);
    });

    test('skips samples missing GPS speed or forward accel', () {
      final samples = <SensorSample>[
        fakeSample(id: 1, timestampUs: 0, gpsSpeed: null, forwardAccel: 5.0),
        fakeSample(id: 2, timestampUs: 1, gpsSpeed: 10, forwardAccel: null),
      ];
      final result = computeMaxAccelAtSpeed(samples);
      for (final r in result) {
        expect(r.peakG, isNull);
      }
    });
  });
}
