import 'dart:math' as math;

import '../../data/database/database.dart';
import 'benchmarks.dart';

/// Standard speed-to-speed and ¼-mile benchmarks.
///
/// Each speed-to-speed benchmark reports the *fastest* qualifying segment
/// in the recording (the driver may have made several attempts). A segment
/// qualifies when forward acceleration is continuous (no negative
/// `forwardAccel` lasting > 0.5 s — i.e. the driver did not lift) and no
/// GPS gap inside it exceeds [kBenchmarkGpsGapToleranceSec].
List<StandardBenchmark> computeStandardBenchmarks(List<SensorSample> samples) {
  return [
    _speedToSpeed(
      samples,
      name: '0–100 km/h',
      startKmh: 0,
      endKmh: 100,
    ),
    _speedToSpeed(
      samples,
      name: '0–60 mph',
      startKmh: 0,
      endKmh: 96.5606, // 60 mph
    ),
    _speedToSpeed(
      samples,
      name: '80–120 km/h',
      startKmh: 80,
      endKmh: 120,
    ),
    _quarterMile(samples),
  ];
}

const double _kQuarterMileMeters = 402.336;
const double _kLiftToleranceSec = 0.5;
const double _kNearStopKmh = 5.0;

StandardBenchmark _speedToSpeed(
  List<SensorSample> samples, {
  required String name,
  required double startKmh,
  required double endKmh,
}) {
  final gpsSamples =
      samples.where((s) => s.gpsSpeed != null).toList(growable: false);
  if (gpsSamples.length < 2) {
    return StandardBenchmark(
      name: name,
      unavailableReason: 'No qualifying acceleration segment found',
    );
  }

  Duration? bestTime;
  int? bestStartUs;
  int? bestEndUs;

  for (var i = 0; i < gpsSamples.length; i++) {
    final startSpeedKmh = gpsSamples[i].gpsSpeed! * 3.6;
    if (startSpeedKmh > startKmh) continue;

    int? endIndex;
    for (var j = i + 1; j < gpsSamples.length; j++) {
      final speedKmh = gpsSamples[j].gpsSpeed! * 3.6;
      if (speedKmh >= endKmh) {
        endIndex = j;
        break;
      }
    }
    if (endIndex == null) continue;

    final segment = gpsSamples.sublist(i, endIndex + 1);
    if (!_segmentValid(segment)) continue;

    final candidate = Duration(
      microseconds: segment.last.timestampUs - segment.first.timestampUs,
    );
    if (bestTime == null || candidate < bestTime) {
      bestTime = candidate;
      bestStartUs = segment.first.timestampUs;
      bestEndUs = segment.last.timestampUs;
    }
  }

  if (bestTime == null) {
    return StandardBenchmark(
      name: name,
      unavailableReason: 'No qualifying acceleration segment found',
    );
  }
  return StandardBenchmark(
    name: name,
    time: bestTime,
    segmentStartUs: bestStartUs,
    segmentEndUs: bestEndUs,
  );
}

bool _segmentValid(List<SensorSample> segment) {
  // Reject if any GPS gap > tolerance.
  for (var i = 1; i < segment.length; i++) {
    final dtSec =
        (segment[i].timestampUs - segment[i - 1].timestampUs) / 1e6;
    if (dtSec > kBenchmarkGpsGapToleranceSec) return false;
  }
  // Reject if forward accel goes negative continuously > _kLiftToleranceSec.
  int? negStartUs;
  for (final s in segment) {
    final fwd = s.forwardAccel;
    if (fwd != null && fwd < 0) {
      negStartUs ??= s.timestampUs;
      final spanSec = (s.timestampUs - negStartUs) / 1e6;
      if (spanSec > _kLiftToleranceSec) return false;
    } else {
      negStartUs = null;
    }
  }
  return true;
}

StandardBenchmark _quarterMile(List<SensorSample> samples) {
  const name = '¼ mile';
  final gpsSamples =
      samples.where((s) => s.gpsSpeed != null).toList(growable: false);
  if (gpsSamples.length < 2) {
    return const StandardBenchmark(
      name: name,
      unavailableReason: 'No qualifying acceleration segment found',
    );
  }

  // The ¼ mile time is conventionally measured from the first sample
  // where the car is at or below a near-stop threshold and then begins to
  // accelerate continuously. Find that first qualifying start and
  // integrate distance until we cross 402.336 m.
  final startIdx = gpsSamples.indexWhere(
    (s) => s.gpsSpeed! * 3.6 <= _kNearStopKmh,
  );
  if (startIdx < 0) {
    return const StandardBenchmark(
      name: name,
      unavailableReason: 'No qualifying acceleration segment found',
    );
  }

  final startUs = gpsSamples[startIdx].timestampUs;
  double distance = 0;
  int? lastUs;
  double? lastSpeed;
  int? negStartUs;

  for (var j = startIdx; j < gpsSamples.length; j++) {
    final s = gpsSamples[j];
    final speed = s.gpsSpeed!;

    if (lastUs != null) {
      final dtSec = (s.timestampUs - lastUs) / 1e6;
      if (dtSec > kBenchmarkGpsGapToleranceSec) break;
      final segDist = (lastSpeed! + speed) * 0.5 * dtSec;

      if (distance + segDist >= _kQuarterMileMeters) {
        final remaining = _kQuarterMileMeters - distance;
        final a = 0.5 * (speed - lastSpeed) / dtSec;
        final b = lastSpeed;
        final c = -remaining;
        double tCross;
        if (a.abs() < 1e-9) {
          tCross = -c / b;
        } else {
          final disc = b * b - 4 * a * c;
          final sqrtDisc = disc <= 0 ? 0.0 : math.sqrt(disc);
          tCross = (-b + sqrtDisc) / (2 * a);
          if (tCross < 0 || tCross > dtSec) {
            tCross = (-b - sqrtDisc) / (2 * a);
          }
        }
        if (tCross.isNaN || tCross < 0) tCross = dtSec;
        if (tCross > dtSec) tCross = dtSec;

        final crossUs = lastUs + (tCross * 1e6).round();
        final trapSpeed = lastSpeed + (speed - lastSpeed) * (tCross / dtSec);
        return StandardBenchmark(
          name: name,
          time: Duration(microseconds: crossUs - startUs),
          segmentStartUs: startUs,
          segmentEndUs: crossUs,
          trapSpeedKmh: trapSpeed * 3.6,
        );
      }

      distance += segDist;
    }

    final fwd = s.forwardAccel;
    if (fwd != null && fwd < 0) {
      negStartUs ??= s.timestampUs;
      final spanSec = (s.timestampUs - negStartUs) / 1e6;
      if (spanSec > _kLiftToleranceSec) break;
    } else {
      negStartUs = null;
    }

    lastUs = s.timestampUs;
    lastSpeed = speed;
  }

  return const StandardBenchmark(
    name: name,
    unavailableReason: 'No qualifying acceleration segment found',
  );
}

