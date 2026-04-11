import 'package:fl_chart/fl_chart.dart';

/// Downsamples a list of FlSpots to at most [maxPoints] for chart rendering.
/// Uses uniform stride sampling to preserve the overall shape.
/// Always keeps the first and last points.
List<FlSpot> downsample(List<FlSpot> spots, {int maxPoints = 500}) {
  if (spots.length <= maxPoints) return spots;

  final result = <FlSpot>[spots.first];
  final stride = (spots.length - 1) / (maxPoints - 1);

  for (int i = 1; i < maxPoints - 1; i++) {
    result.add(spots[(i * stride).round()]);
  }
  result.add(spots.last);
  return result;
}
