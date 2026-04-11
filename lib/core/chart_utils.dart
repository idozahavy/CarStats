import 'package:fl_chart/fl_chart.dart';

/// Downsamples a list of FlSpots to at most [maxPoints] for chart rendering.
///
/// When [xMin] and [xMax] are provided, uses **fixed X-axis bucket sampling**:
/// the X range is divided into [maxPoints] equal buckets with fixed boundaries.
/// Each point deterministically maps to one bucket (last-write-wins within a
/// bucket), so adding new data never shifts previously placed points — no jitter.
///
/// Without [xMin]/[xMax], falls back to uniform stride sampling (suitable for
/// static/post-recording charts where live jitter is not a concern).
List<FlSpot> downsample(
  List<FlSpot> spots, {
  int maxPoints = 500,
  double? xMin,
  double? xMax,
}) {
  if (spots.length <= maxPoints) return spots;

  if (xMin != null && xMax != null && xMax > xMin) {
    // Fixed-bucket mode: deterministic regardless of list length.
    final bucketWidth = (xMax - xMin) / maxPoints;
    final buckets = List<FlSpot?>.filled(maxPoints, null);
    for (final spot in spots) {
      final idx = ((spot.x - xMin) / bucketWidth).floor().clamp(
        0,
        maxPoints - 1,
      );
      buckets[idx] = spot;
    }
    return buckets.whereType<FlSpot>().toList();
  }

  // Stride mode: preserves shape for static data.
  final result = <FlSpot>[spots.first];
  final stride = (spots.length - 1) / (maxPoints - 1);
  for (int i = 1; i < maxPoints - 1; i++) {
    result.add(spots[(i * stride).round()]);
  }
  result.add(spots.last);
  return result;
}
