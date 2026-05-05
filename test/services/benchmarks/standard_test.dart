import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/services/benchmarks/standard.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  group('computeStandardBenchmarks', () {
    test('0–100 in exactly 5 s yields 5 s with positive accel', () {
      // 50 Hz from 0 → 100 km/h in 5 s. 100 km/h = 27.7778 m/s.
      // Average accel = 5.5556 m/s². Use linear ramp.
      final samples = <SensorSample>[];
      const dtUs = 20000;
      for (var i = 0; i <= 250; i++) {
        final t = i * dtUs / 1e6;
        final speed = 5.5556 * t; // m/s
        samples.add(_sample(i, i * dtUs, speed: speed, fwd: 5.5556));
      }
      final b = computeStandardBenchmarks(samples);
      final s100 = b.firstWhere((e) => e.name == '0–100 km/h');
      expect(s100.time, isNotNull);
      // 100 km/h = 27.7778 m/s reached at t = 5.0 s exactly.
      expect(s100.time!.inMilliseconds, closeTo(5000, 50));
    });

    test('0–60 mph and 80–120 km/h available on a synthetic 0→200 sweep',
        () {
      // 50 Hz, 200 km/h in 10 s → 5.5556 m/s² for the full window.
      // Should populate all three speed-to-speed benchmarks.
      final samples = <SensorSample>[];
      const dtUs = 20000;
      for (var i = 0; i <= 500; i++) {
        final t = i * dtUs / 1e6;
        final speed = 5.5556 * t;
        samples.add(_sample(i, i * dtUs, speed: speed, fwd: 5.5556));
      }
      final b = computeStandardBenchmarks(samples);
      expect(b.firstWhere((e) => e.name == '0–100 km/h').time, isNotNull);
      expect(b.firstWhere((e) => e.name == '0–60 mph').time, isNotNull);
      expect(b.firstWhere((e) => e.name == '80–120 km/h').time, isNotNull);
    });

    test('lift mid-pull invalidates 0–100', () {
      // Ramp up to ~80 km/h in 4 s, then sustained negative accel for 1 s
      // (driver lifts), then continue back up to 100. Continuous segment
      // is broken so 0–100 should report unavailable.
      final samples = <SensorSample>[];
      const dtUs = 20000;
      double speedMs = 0;
      for (var i = 0; i <= 400; i++) {
        final t = i * dtUs / 1e6;
        double accel;
        if (t < 4.0) {
          accel = 5.5556;
        } else if (t < 5.0) {
          accel = -2.0; // sustained negative > 0.5 s
        } else {
          accel = 5.5556;
        }
        speedMs += accel * (dtUs / 1e6);
        if (speedMs < 0) speedMs = 0;
        samples.add(_sample(i, i * dtUs, speed: speedMs, fwd: accel));
      }
      final b = computeStandardBenchmarks(samples);
      final s100 = b.firstWhere((e) => e.name == '0–100 km/h');
      expect(s100.time, isNull);
      expect(s100.unavailableReason, isNotNull);
    });

    test('GPS gap > 2 s inside segment invalidates 0–100', () {
      // Two halves separated by a 3 s gap (no samples between).
      final samples = <SensorSample>[];
      const dtUs = 20000;
      // First 2 s @ 5.5556 m/s² → 11.11 m/s = 40 km/h.
      for (var i = 0; i <= 100; i++) {
        final t = i * dtUs / 1e6;
        samples.add(_sample(i, i * dtUs, speed: 5.5556 * t, fwd: 5.5556));
      }
      // 3 s gap, then resume at 40 km/h and ramp to 100 km/h in 3 s.
      final gapEndUs = 100 * dtUs + 3000000;
      final startSpeed = 5.5556 * 2.0;
      for (var i = 1; i <= 150; i++) {
        final t = i * dtUs / 1e6;
        final speed = startSpeed + 5.5556 * t;
        samples.add(_sample(
          1000 + i,
          gapEndUs + i * dtUs,
          speed: speed,
          fwd: 5.5556,
        ));
      }
      final b = computeStandardBenchmarks(samples);
      final s100 = b.firstWhere((e) => e.name == '0–100 km/h');
      expect(s100.time, isNull);
    });

    test('¼ mile from constant-accel run produces a time with trap speed',
        () {
      // Constant 4 m/s² from rest. d = 0.5 * 4 * t² ⇒ t at 402.336 m
      // ⇒ t = sqrt(2*402.336/4) ≈ 14.18 s. Trap speed ≈ 56.74 m/s.
      final samples = <SensorSample>[];
      const dtUs = 20000;
      for (var i = 0; i <= 1000; i++) {
        final t = i * dtUs / 1e6;
        final speed = 4.0 * t;
        samples.add(_sample(i, i * dtUs, speed: speed, fwd: 4.0));
      }
      final b = computeStandardBenchmarks(samples);
      final qm = b.firstWhere((e) => e.name == '¼ mile');
      expect(qm.time, isNotNull);
      expect(qm.time!.inMilliseconds, closeTo(14180, 200));
      expect(qm.trapSpeedKmh, isNotNull);
      // 56.74 m/s ≈ 204.3 km/h — large but synthetic; just sanity check.
      expect(qm.trapSpeedKmh!, greaterThan(190));
    });
  });
}

SensorSample _sample(
  int id,
  int tsUs, {
  required double speed,
  required double fwd,
}) {
  return fakeSample(
    id: id,
    timestampUs: tsUs,
    gpsSpeed: speed,
    forwardAccel: fwd,
  );
}
