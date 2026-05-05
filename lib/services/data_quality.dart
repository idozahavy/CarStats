import '../data/database/database.dart';

/// Phase 07 — quantitative quality grade for a finished recording.
///
/// Computed from the persisted `SensorSamples` after the recording ends.
/// Surfaced on the recording detail screen so users see at a glance
/// whether a recording is reliable enough to trust for benchmarking.
enum QualityGrade { green, amber, red }

class DataQuality {
  final double sampleRateHz;
  final double gpsCoveragePercent;
  final double headingLockedPercent;
  final QualityGrade sampleRateGrade;
  final QualityGrade gpsCoverageGrade;
  final QualityGrade headingLockedGrade;

  const DataQuality({
    required this.sampleRateHz,
    required this.gpsCoveragePercent,
    required this.headingLockedPercent,
    required this.sampleRateGrade,
    required this.gpsCoverageGrade,
    required this.headingLockedGrade,
  });

  /// Worst grade across the three metrics — drives the overall pill.
  QualityGrade get overall {
    if (sampleRateGrade == QualityGrade.red ||
        gpsCoverageGrade == QualityGrade.red ||
        headingLockedGrade == QualityGrade.red) {
      return QualityGrade.red;
    }
    if (sampleRateGrade == QualityGrade.amber ||
        gpsCoverageGrade == QualityGrade.amber ||
        headingLockedGrade == QualityGrade.amber) {
      return QualityGrade.amber;
    }
    return QualityGrade.green;
  }
}

/// Thresholds — pinned in phase 07. See `.wiki/concepts/acceleration-calculation.md`
/// for the rationale.
class DataQualityThresholds {
  static const double sampleRateGreenHz = 45;
  static const double sampleRateAmberHz = 30;
  static const double gpsCoverageGreenPercent = 95;
  static const double gpsCoverageAmberPercent = 80;
  static const double headingLockedGreenPercent = 80;
  static const double headingLockedAmberPercent = 50;
}

QualityGrade _gradeBy(double value, double greenAt, double amberAt) {
  if (value >= greenAt) return QualityGrade.green;
  if (value >= amberAt) return QualityGrade.amber;
  return QualityGrade.red;
}

/// Computes [DataQuality] from a recording's sample list and duration.
///
/// `headingLockedPercent` is a proxy: it counts samples with a non-null
/// `forwardAccel` after the first non-null sample. Forward accel is null
/// only before calibration produces a decomposer (which only happens for
/// orphan/corrupt rows); in practice a healthy post-calibration recording
/// scores 100% on this metric. A future iteration may store the
/// `headingCalibrated` bit on the sample to let the proxy distinguish
/// pre- from post-lock samples.
DataQuality computeDataQuality(List<SensorSample> samples, int durationMs) {
  if (samples.isEmpty || durationMs <= 0) {
    return const DataQuality(
      sampleRateHz: 0,
      gpsCoveragePercent: 0,
      headingLockedPercent: 0,
      sampleRateGrade: QualityGrade.red,
      gpsCoverageGrade: QualityGrade.red,
      headingLockedGrade: QualityGrade.red,
    );
  }

  final durationSec = durationMs / 1000.0;
  final sampleRateHz = samples.length / durationSec;

  final gpsCount = samples.where((s) => s.gpsSpeed != null).length;
  final gpsCoveragePercent = gpsCount * 100.0 / samples.length;

  final firstForwardIndex =
      samples.indexWhere((s) => s.forwardAccel != null);
  final double headingLockedPercent;
  if (firstForwardIndex < 0) {
    headingLockedPercent = 0;
  } else {
    final tail = samples.length - firstForwardIndex;
    final lockedCount = samples
        .sublist(firstForwardIndex)
        .where((s) => s.forwardAccel != null)
        .length;
    headingLockedPercent = lockedCount * 100.0 / tail;
  }

  return DataQuality(
    sampleRateHz: sampleRateHz,
    gpsCoveragePercent: gpsCoveragePercent,
    headingLockedPercent: headingLockedPercent,
    sampleRateGrade: _gradeBy(
      sampleRateHz,
      DataQualityThresholds.sampleRateGreenHz,
      DataQualityThresholds.sampleRateAmberHz,
    ),
    gpsCoverageGrade: _gradeBy(
      gpsCoveragePercent,
      DataQualityThresholds.gpsCoverageGreenPercent,
      DataQualityThresholds.gpsCoverageAmberPercent,
    ),
    headingLockedGrade: _gradeBy(
      headingLockedPercent,
      DataQualityThresholds.headingLockedGreenPercent,
      DataQualityThresholds.headingLockedAmberPercent,
    ),
  );
}
