import '../../data/database/database.dart';
import 'benchmarks.dart';

/// Peak forward acceleration (in g) per discrete speed bucket.
///
/// Buckets are centred at [kMaxAccelSpeedBucketsKmh] with half-width
/// [kMaxAccelBucketHalfWidthKmh] km/h. Samples missing either GPS speed or
/// forward accel are skipped. A bucket with no qualifying sample reports
/// `peakG: null`.
List<MaxAccelAtSpeed> computeMaxAccelAtSpeed(List<SensorSample> samples) {
  return [
    for (final centre in kMaxAccelSpeedBucketsKmh)
      _peakInBucket(samples, centre),
  ];
}

MaxAccelAtSpeed _peakInBucket(List<SensorSample> samples, int centreKmh) {
  final lo = centreKmh - kMaxAccelBucketHalfWidthKmh;
  final hi = centreKmh + kMaxAccelBucketHalfWidthKmh;

  double? peakG;
  int? peakUs;
  for (final s in samples) {
    final speed = s.gpsSpeed;
    final fwd = s.forwardAccel;
    if (speed == null || fwd == null) continue;
    final speedKmh = speed * 3.6;
    if (speedKmh < lo || speedKmh > hi) continue;
    final g = fwd / 9.81;
    if (peakG == null || g > peakG) {
      peakG = g;
      peakUs = s.timestampUs;
    }
  }
  return MaxAccelAtSpeed(
    speedBucketKmh: centreKmh,
    peakG: peakG,
    sampleTimestampUs: peakUs,
  );
}
