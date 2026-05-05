import '../../data/database/database.dart';
import 'benchmarks.dart';

/// Detects sudden-acceleration events at cruise speed.
///
/// A cruise window is a contiguous run of samples (with GPS speed) of at
/// least [kSuddenAccelCruiseWindowSec] seconds where speed stays within
/// ±[kSuddenAccelCruiseToleranceKmh] km/h of the window's mean. The
/// detector then scans up to [kSuddenAccelMaxLookaheadSec] seconds past
/// the cruise end for the first sample where forward G exceeds
/// [kSuddenAccelTriggerG] AND stays above it for at least
/// [kSuddenAccelMinSustainSec] seconds.
List<SuddenAccelEvent> computeSuddenAccelEvents(List<SensorSample> samples) {
  if (samples.isEmpty) return const [];

  final events = <SuddenAccelEvent>[];

  // Walk the sample list, building cruise windows greedily. Each event
  // consumes its trigger so we don't double-report overlapping bursts.
  int i = 0;
  while (i < samples.length) {
    final cruiseEnd = _findCruiseWindowEnd(samples, i);
    if (cruiseEnd == null) {
      i++;
      continue;
    }
    final cruiseSpeedKmh = _meanSpeedKmh(samples, i, cruiseEnd);
    final event = _scanForTrigger(
      samples,
      cruiseEndIndex: cruiseEnd,
      cruiseSpeedKmh: cruiseSpeedKmh,
    );
    if (event != null) {
      events.add(event);
      // Skip past the burst end (rough — advance past trigger by sustain).
      i = cruiseEnd + 1;
      while (i < samples.length &&
          (samples[i].timestampUs - event.triggerTimestampUs) / 1e6 <
              kSuddenAccelMinSustainSec) {
        i++;
      }
      continue;
    }
    // No trigger — advance past the cruise window so we look for the next.
    i = cruiseEnd + 1;
  }

  return events;
}

/// Returns the index (inclusive) of the last sample of a cruise window
/// starting at [startIndex], or null if no qualifying window starts there.
int? _findCruiseWindowEnd(List<SensorSample> samples, int startIndex) {
  if (samples[startIndex].gpsSpeed == null) return null;
  final startUs = samples[startIndex].timestampUs;
  final startSpeed = samples[startIndex].gpsSpeed! * 3.6;
  double minKmh = startSpeed;
  double maxKmh = startSpeed;

  int? end;
  for (var j = startIndex + 1; j < samples.length; j++) {
    final speed = samples[j].gpsSpeed;
    if (speed == null) return end; // GPS gap breaks the window.
    final kmh = speed * 3.6;
    if (kmh < minKmh) minKmh = kmh;
    if (kmh > maxKmh) maxKmh = kmh;
    if (maxKmh - minKmh > 2 * kSuddenAccelCruiseToleranceKmh) {
      // Spread exceeded — window ends at j-1.
      return end;
    }
    final spanSec = (samples[j].timestampUs - startUs) / 1e6;
    if (spanSec >= kSuddenAccelCruiseWindowSec) {
      end = j;
    }
  }
  return end;
}

double _meanSpeedKmh(List<SensorSample> samples, int from, int toInclusive) {
  double sum = 0;
  int count = 0;
  for (var i = from; i <= toInclusive; i++) {
    final s = samples[i].gpsSpeed;
    if (s == null) continue;
    sum += s * 3.6;
    count++;
  }
  return count == 0 ? 0 : sum / count;
}

SuddenAccelEvent? _scanForTrigger(
  List<SensorSample> samples, {
  required int cruiseEndIndex,
  required double cruiseSpeedKmh,
}) {
  final cruiseEndUs = samples[cruiseEndIndex].timestampUs;
  // Find first sample after cruise end where forwardAccel > 0.2 g and
  // stays > 0.2 g for >= sustain seconds.
  for (var j = cruiseEndIndex + 1; j < samples.length; j++) {
    final dtSec = (samples[j].timestampUs - cruiseEndUs) / 1e6;
    if (dtSec > kSuddenAccelMaxLookaheadSec) return null;
    final fwd = samples[j].forwardAccel;
    if (fwd == null) continue;
    final g = fwd / 9.81;
    if (g <= kSuddenAccelTriggerG) continue;

    // Verify sustain.
    double peakG = g;
    int? lastSustainedUs = samples[j].timestampUs;
    bool sustained = false;
    for (var k = j; k < samples.length; k++) {
      final fk = samples[k].forwardAccel;
      if (fk == null) continue;
      final gk = fk / 9.81;
      if (gk <= kSuddenAccelTriggerG) break;
      if (gk > peakG) peakG = gk;
      lastSustainedUs = samples[k].timestampUs;
      final sustainSec = (lastSustainedUs - samples[j].timestampUs) / 1e6;
      if (sustainSec >= kSuddenAccelMinSustainSec) {
        sustained = true;
      }
    }
    if (!sustained) continue;

    return SuddenAccelEvent(
      cruiseSpeedKmh: cruiseSpeedKmh,
      responseTime: Duration(
        microseconds: samples[j].timestampUs - cruiseEndUs,
      ),
      peakG: peakG,
      triggerTimestampUs: samples[j].timestampUs,
    );
  }
  return null;
}
