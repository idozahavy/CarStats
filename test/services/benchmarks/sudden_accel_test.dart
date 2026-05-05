import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/services/benchmarks/sudden_accel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  group('computeSuddenAccelEvents', () {
    test('cruise at 80 then floor it produces one event', () {
      // 5 s cruise at 80 km/h, then 2 s of 0.5 g pull.
      final samples = <SensorSample>[];
      const dtUs = 20000;
      const cruiseSpeed = 80 / 3.6; // m/s
      double t = 0;
      int id = 0;
      // Cruise.
      for (var i = 0; i < 250; i++) {
        samples.add(fakeSample(
          id: id++,
          timestampUs: (t * 1e6).round(),
          gpsSpeed: cruiseSpeed,
          forwardAccel: 0.0,
        ));
        t += dtUs / 1e6;
      }
      // Burst — 0.5 g for 2 s.
      double speed = cruiseSpeed;
      for (var i = 0; i < 100; i++) {
        speed += 4.905 * (dtUs / 1e6);
        samples.add(fakeSample(
          id: id++,
          timestampUs: (t * 1e6).round(),
          gpsSpeed: speed,
          forwardAccel: 4.905, // 0.5 g
        ));
        t += dtUs / 1e6;
      }

      final events = computeSuddenAccelEvents(samples);
      expect(events.length, 1);
      final e = events.first;
      expect(e.cruiseSpeedKmh, closeTo(80, 0.5));
      expect(e.peakG, closeTo(0.5, 0.05));
      // Response time is the gap between the cruise window's end and the
      // first triggering sample — for synthetic back-to-back samples that
      // is one sample period.
      expect(e.responseTime.inMilliseconds, lessThan(60));
    });

    test('cruise then small bump (0.1 g) produces no event', () {
      final samples = <SensorSample>[];
      const dtUs = 20000;
      const cruiseSpeed = 80 / 3.6;
      double t = 0;
      int id = 0;
      for (var i = 0; i < 250; i++) {
        samples.add(fakeSample(
          id: id++,
          timestampUs: (t * 1e6).round(),
          gpsSpeed: cruiseSpeed,
          forwardAccel: 0.0,
        ));
        t += dtUs / 1e6;
      }
      double speed = cruiseSpeed;
      for (var i = 0; i < 100; i++) {
        speed += 0.981 * (dtUs / 1e6);
        samples.add(fakeSample(
          id: id++,
          timestampUs: (t * 1e6).round(),
          gpsSpeed: speed,
          forwardAccel: 0.981, // 0.1 g, below the 0.2 g trigger
        ));
        t += dtUs / 1e6;
      }
      final events = computeSuddenAccelEvents(samples);
      expect(events, isEmpty);
    });
  });
}
