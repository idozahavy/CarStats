import '../../data/database/database.dart';
import 'max_accel_at_speed.dart';
import 'standard.dart';
import 'sudden_accel.dart';

/// Phase 08 — derived benchmark numbers from a finished recording.
///
/// All calculators are pure functions over the persisted `SensorSamples`
/// list. No DB writes, no state — results are recomputed on each
/// detail-screen open.
class StandardBenchmark {
  final String name;
  final Duration? time;
  final int? segmentStartUs;
  final int? segmentEndUs;
  final double? trapSpeedKmh;
  final String? unavailableReason;

  const StandardBenchmark({
    required this.name,
    this.time,
    this.segmentStartUs,
    this.segmentEndUs,
    this.trapSpeedKmh,
    this.unavailableReason,
  });

  bool get isAvailable => time != null;
}

class MaxAccelAtSpeed {
  final int speedBucketKmh;
  final double? peakG;
  final int? sampleTimestampUs;

  const MaxAccelAtSpeed({
    required this.speedBucketKmh,
    this.peakG,
    this.sampleTimestampUs,
  });
}

class SuddenAccelEvent {
  final double cruiseSpeedKmh;
  final Duration responseTime;
  final double peakG;
  final int triggerTimestampUs;

  const SuddenAccelEvent({
    required this.cruiseSpeedKmh,
    required this.responseTime,
    required this.peakG,
    required this.triggerTimestampUs,
  });
}

class BenchmarkReport {
  final List<StandardBenchmark> standard;
  final List<MaxAccelAtSpeed> maxAccelByBucket;
  final List<SuddenAccelEvent> suddenAccelEvents;

  const BenchmarkReport({
    required this.standard,
    required this.maxAccelByBucket,
    required this.suddenAccelEvents,
  });

  static const BenchmarkReport empty = BenchmarkReport(
    standard: [],
    maxAccelByBucket: [],
    suddenAccelEvents: [],
  );
}

/// Speed-bucket centres in km/h for the max-accel-at-speed report.
const List<int> kMaxAccelSpeedBucketsKmh = [
  0,
  20,
  40,
  60,
  80,
  100,
  120,
  140,
];

/// Half-width of the speed bucket window in km/h.
const double kMaxAccelBucketHalfWidthKmh = 10;

/// GPS gap (seconds) above which a candidate standard-benchmark segment is
/// rejected.
const double kBenchmarkGpsGapToleranceSec = 2.0;

/// Cruise window length (seconds) and tolerance (km/h) for the sudden-accel
/// detector.
const double kSuddenAccelCruiseWindowSec = 3.0;
const double kSuddenAccelCruiseToleranceKmh = 2.0;

/// Forward-G trigger and minimum sustain duration for sudden-accel.
const double kSuddenAccelTriggerG = 0.2;
const double kSuddenAccelMinSustainSec = 0.5;

/// Maximum lookahead from cruise end to trigger sample (seconds).
const double kSuddenAccelMaxLookaheadSec = 2.0;

/// Single entry point: compute every benchmark series for a sample list.
BenchmarkReport computeBenchmarks(List<SensorSample> samples) {
  if (samples.isEmpty) return BenchmarkReport.empty;
  return BenchmarkReport(
    standard: computeStandardBenchmarks(samples),
    maxAccelByBucket: computeMaxAccelAtSpeed(samples),
    suddenAccelEvents: computeSuddenAccelEvents(samples),
  );
}
