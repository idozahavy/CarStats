# Phase 08 — Benchmarks

## Goal
Compute and display benchmark numbers from any user recording: 0–100 km/h, 0–60 mph, 80–120 km/h, ¼ mile (400 m), max acceleration at speed buckets, and sudden-acceleration-at-speed response. No DB writes — results are derived on demand.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/features/benchmarks.md` (planned), `.wiki/data-model.md`, `.wiki/concepts/acceleration-calculation.md`, `.wiki/features/recording-history.md`.

**Code layout**:
- `lib/screens/recording_detail/recording_detail_screen.dart` — entry point for benchmarks
- `lib/data/database/database.dart` — `SensorSample` definition
- `lib/services/` — pure-function services live here

**Hard rules**:
- Read a file before modifying it.
- Pure-function calculators only — no state, no side effects.
- Update wiki per `.wiki/SCHEMA.md`.

## Decisions already made (do not relitigate)

- **Standard benchmarks (MVP)**: 0–100 km/h, 0–60 mph, 80–120 km/h, ¼ mile (400 m).
- **Max-accel-at-speed buckets**: 0, 20, 40, 60, 80, 100, 120, 140 km/h. Bucket width ±10 km/h around the centre.
- **GPS gap tolerance**: invalidate a candidate segment if any GPS gap > 2 s inside it.
- **Units**: km/h default. No mph toggle yet (we still report 0–60 mph internally by converting).
- **Sudden-accel-at-speed detection**:
  - Cruise condition: speed within ±2 km/h for ≥3 s.
  - Trigger: forward G > 0.2 g sustained for ≥0.5 s after cruise.
  - Report: cruise speed, response time (cruise end → trigger), peak G during the burst.
- **No DB writes**. Results derived on each detail-screen open.

## Scope

**In:**
- Pure-function benchmark calculators in `lib/services/benchmarks/`
- A "Benchmarks" tab/section on the recording detail screen
- Per-benchmark display: value, qualifying segment timestamp range, "no qualifying segment" empty state
- Tests for each calculator with synthetic input
- Filter: only show benchmarks for recordings where `isDevRecording == false` (dev recordings still display, but with a "Dev recording — results may be unreliable" banner)

**Out:**
- DB persistence of benchmark results
- Cross-recording comparison (Phase 09 — overlay)
- Configurable thresholds in UI

## Tasks (ordered)

### A. Calculator scaffolding
File: `lib/services/benchmarks/benchmarks.dart` (new) and helpers under `lib/services/benchmarks/*.dart`

1. Define result types:
   ```dart
   class StandardBenchmark {
     final String name;        // "0–100 km/h"
     final Duration? time;     // null = no qualifying segment
     final int? segmentStartUs;
     final int? segmentEndUs;
     final String? unavailableReason;
   }

   class MaxAccelAtSpeed {
     final int speedBucketKmh;
     final double? peakG;
     final int? sampleTimestampUs;
   }

   class SuddenAccelEvent {
     final double cruiseSpeedKmh;
     final Duration responseTime;
     final double peakG;
     final int triggerTimestampUs;
   }

   class BenchmarkReport {
     final List<StandardBenchmark> standard;
     final List<MaxAccelAtSpeed> maxAccelByBucket;
     final List<SuddenAccelEvent> suddenAccelEvents;
   }
   ```

2. Single entry point:
   ```dart
   BenchmarkReport computeBenchmarks(List<SensorSample> samples);
   ```

### B. Standard benchmarks
File: `lib/services/benchmarks/standard.dart`

For each of (0→100 km/h), (0→60 mph = 96.56 km/h), (80→120 km/h):
1. Walk samples chronologically. For each candidate start (first sample where `gpsSpeed*3.6 ≤ startKmh`), find the earliest later sample where `gpsSpeed*3.6 ≥ endKmh`.
2. Within the candidate segment, validate:
   - Continuous forward acceleration (no negative `forwardAccel` lasting > 0.5 s — driver did not lift)
   - No GPS gap > 2 s (consecutive samples with `gpsSpeed != null` more than 2 s apart fail)
3. Pick the *fastest* qualifying segment in the recording. If none: `unavailableReason: "No qualifying acceleration segment found"`.

For ¼ mile:
1. Find the longest contiguous forward-acceleration segment starting from a near-stop (`gpsSpeed*3.6 ≤ 5`).
2. Integrate distance via trapezoidal rule on `gpsSpeed`. If total distance ≥ 402.336 m within the segment, the time at 402.336 m is the ¼ mile time. Trap speed = `gpsSpeed` at the 402.336 m point.

### C. Max accel at speed bucket
File: `lib/services/benchmarks/max_accel_at_speed.dart`

For each bucket centre c in {0, 20, 40, 60, 80, 100, 120, 140}:
1. Filter samples where `gpsSpeed*3.6` is in `[c-10, c+10]`.
2. The peak G at this bucket = `max(forwardAccel) / 9.81` over those samples.
3. If no samples in bucket: `peakG: null`.

### D. Sudden accel events
File: `lib/services/benchmarks/sudden_accel.dart`

1. Walk samples with a sliding window. Identify "cruise windows" of ≥3 s where speed range ≤ 2 km/h.
2. For each cruise window's end, scan forward up to 2 s for the first sample where `forwardAccel > 0.2 g` AND this stays true for ≥0.5 s.
3. If found, record event with cruise speed (mean over the window), response time (cruise end → trigger sample), peak G during the burst (until forward G drops below 0.2 g).

### E. UI integration
File: `lib/screens/recording_detail/recording_detail_screen.dart`

1. Below the existing charts, add a "Benchmarks" section. Compute via `computeBenchmarks(_samples)` (compute lazily — wrap with `late final` or call once in the build path; the dataset can be 3000+ samples but is in-memory so this is fine for MVP).
2. Render three sub-sections:
   - **Standard**: 4 cards in a row (or wrap on narrow screens), each showing benchmark name + time (or "—" with `unavailableReason` as a tooltip).
   - **Max Accel at Speed**: a small bar-chart or list showing each bucket and its peak G.
   - **Sudden Acceleration**: a list of events; empty state if none.
3. If `_recording.isDevRecording`, render an `Banner` widget at the top of the section: "Dev recording — benchmark results may be unreliable."

### F. Tests
File: `test/services/benchmarks/`

1. `standard_test.dart`:
   - Synthetic 0→100 in exactly 5 s → returns 5 s.
   - Recording that lifts mid-pull → 0→100 unavailable (no continuous segment).
   - GPS gap inside segment → segment invalidated.
   - ¼ mile from synthetic constant-accel run.
2. `max_accel_at_speed_test.dart`:
   - Recording with peak 0.6 g around 60 km/h → bucket 60 reports 0.6 g; surrounding buckets lower.
   - Empty bucket → `peakG: null`.
3. `sudden_accel_test.dart`:
   - Cruise at 80 km/h for 5 s, then floor it → one event with response time near 0 and peak G matching input.
   - Cruise at 80 then small bump (0.1 g) → no event.
4. `test/screens/recording_detail_screen_test.dart` extension:
   - Detail screen renders benchmark cards for a fixture with computed values.
   - Dev-recording fixture shows the warning banner.

### G. Verify
- `flutter analyze` — clean
- `flutter test` — all green
- Manual: open a real recording on device and confirm benchmarks render sensibly.

### H. Wiki updates
- `.wiki/features/benchmarks.md` — flip status from "Planned" to current. Replace `_TBD_` markers. Document thresholds, bucket widths, gap tolerance.
- `.wiki/features/recording-history.md` — note the Benchmarks section on detail screen.
- `.wiki/architecture.md` — add `lib/services/benchmarks/` to the Layers table under "Math".
- `.wiki/log.md` — append dated entry.

## Acceptance criteria

- `BenchmarkReport computeBenchmarks(List<SensorSample>)` returns the four result lists deterministically
- Detail screen shows standard benchmarks, max-accel-at-speed buckets, and sudden-accel events
- Dev recordings show the unreliability warning banner
- All calculators have synthetic-input tests covering happy path + at least one rejection path
- All tests green; analyzer clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/features/benchmarks.md` (flip from planned)
- `.wiki/features/recording-history.md`
- `.wiki/architecture.md`
- `.wiki/log.md` (append entry)
