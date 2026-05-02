# Phase 07 — Recording-Pipeline Validation

## Goal
Prove the recording pipeline produces accurate data for benchmark computation. Build a synthetic-input harness that simulates known driving scenarios and asserts the recorded outputs match expectations. Add a data-quality badge to the detail screen so users see when a recording is reliable.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/concepts/acceleration-calculation.md`, `.wiki/architecture.md`, `.wiki/features/recording.md`, `.wiki/data-model.md`.

**Code layout**:
- `lib/services/recording_engine.dart` — orchestration, sample assembly
- `lib/services/calibration_service.dart` — `CalibrationService`, `HeadingCalibrator`, `AccelerationDecomposer`
- `lib/services/sensor_service.dart` — sensor stream wrappers
- `lib/services/gps_service.dart` — GPS stream wrapper
- `lib/data/database/database.dart` — `Recording`, `SensorSample`
- `lib/screens/recording_detail/recording_detail_screen.dart` — where the badge will live
- `test/services/rotation_with_gps_integration_test.dart` — existing integration test pattern to follow
- `test/helpers/fakes.dart` — fakes for `RecordingStore`

**Hard rules**:
- Read a file before modifying it.
- After schema edits run `dart run build_runner build --delete-conflicting-outputs` (no schema edits this phase).
- Tests use `engine.flushInterval = Duration.zero` and `engine.useCalibrationTimer = false`.
- Update wiki per `.wiki/SCHEMA.md`.

## Why this phase exists

Benchmarks (next phase) depend on `forwardAccel` and `gpsSpeed` being accurate, sample timing being monotonic and dense (~50 Hz), and heading lock converging within a few seconds of motion. None of this is currently asserted end-to-end against scenarios that mirror real driving. Without this validation, benchmark numbers will be unverifiable.

## Scope

**In:**
- A scenario-driven test harness that injects synthetic accel + gyro + GPS streams into the real `RecordingEngine`
- Five concrete scenarios with quantitative assertions
- Helper functions to compute data-quality metrics from a `List<SensorSample>`
- A "Data Quality" widget on the recording detail screen showing sample rate, GPS coverage %, heading-locked %
- Wiki documentation of acceptable-quality thresholds

**Out:**
- Schema changes (no new tables)
- Changes to recording-engine logic unless a scenario reveals a bug — surface bugs to the user before fixing in this phase
- Benchmark calculation (Phase 08)

## Decisions already made (do not relitigate)

- **Synthetic harness location**: `test/scenarios/` (new folder). One file per scenario.
- **Data-quality thresholds** (used by the badge):
  - Sample rate: green ≥ 45 Hz, amber ≥ 30 Hz, red < 30 Hz
  - GPS coverage (samples with `gpsSpeed != null`): green ≥ 95%, amber ≥ 80%, red < 80%
  - Heading lock fraction (samples after the first heading-locked sample / total): green ≥ 80%, amber ≥ 50%, red < 50%
- **No `RecordingEngine` API changes**. Drive it via the existing `SensorService` and `GpsService` interfaces by injecting fake services that expose the controllers.

## Tasks (ordered)

### A. Build synthetic injection helpers
File: `test/scenarios/synthetic_drive.dart` (new)

1. Create `class FakeSensorService implements SensorService` with public `StreamController`s for accel/gyro/linear-accel/barometer that tests can push into. Already partially exists in `test/helpers/fakes.dart` — extend or reuse.
2. Create `class FakeGpsService implements GpsService` similarly.
3. Add a helper:
   ```dart
   /// Generate sensor + GPS samples for a scenario where the car accelerates
   /// from 0 to [targetSpeedKmh] with constant forward accel [accelG] over
   /// [durationSec], holding the phone perfectly level (no rotation).
   Future<void> simulateConstantAccelRun(...);
   ```
4. Add a similar helper for `simulateBrakingRun(...)` and `simulateSteadyCruise(...)`.

### B. Scenario tests
File: `test/scenarios/recording_pipeline_test.dart` (new)

Each scenario constructs a real `RecordingEngine` with fake services, runs the simulation, stops the engine, reads the recorded samples back from a fake DB, and asserts:

1. **Scenario 1 — 0 to 100 km/h, 5-second pull, ~0.57 g forward**
   - Wait for calibration (skip via `useCalibrationTimer = false` + `finishCalibrationNow`).
   - Inject 5 s of accel + GPS samples representing constant 0.57 g forward.
   - Assert: integrating the recorded `forwardAccel` over time recovers the GPS speed within 5% at the end.
   - Assert: `gpsSpeed` at t=5s is within 2 km/h of 100 km/h.
   - Assert: `forwardAccel` mean is within 5% of 5.59 m/s² (0.57 × 9.81).

2. **Scenario 2 — Hard brake, 100 → 0 km/h in 4 s**
   - Inject braking samples (negative forward accel ~ -0.71 g).
   - Assert: minimum `forwardAccel` ≤ -6.5 m/s².
   - Assert: integrated speed change recovers ~ -100 km/h.

3. **Scenario 3 — Heading-lock convergence**
   - Inject 10 s of varied accel/decel events with consistent GPS heading.
   - Assert: at least one sample has a calibrated heading within the first 8 events of qualifying motion.
   - Assert: after lock, decomposed forward axis aligns with true forward within ±15°.

4. **Scenario 4 — Sample rate and timestamp monotonicity**
   - Inject 60 s of samples at 50 Hz.
   - Assert: `samples.length` is within 5% of 3000.
   - Assert: every consecutive `timestampUs` is strictly greater than the previous.
   - Assert: median delta between consecutive timestamps is within ±2 ms of 20 000 µs.

5. **Scenario 5 — GPS dropout resilience**
   - Inject 30 s with a 5-second GPS gap in the middle (sensors keep flowing).
   - Assert: recording completes without crash.
   - Assert: samples during the gap have `gpsSpeed == null` but `accelX/Y/Z` populated.
   - Assert: GPS coverage helper computes ≈ 83% (25/30).

If any scenario fails — **do not silently fix the production code**. Stop, surface the failure to the user with the exact scenario, expected vs actual values, and suggested fix locations. The user decides whether to patch in this phase or open a follow-up.

### C. Data-quality helper
File: `lib/services/data_quality.dart` (new)

```dart
class DataQuality {
  final double sampleRateHz;
  final double gpsCoveragePercent;
  final double headingLockedPercent;
  final QualityGrade overall;
  // ... constructor, computed property, etc.
}

enum QualityGrade { green, amber, red }

DataQuality computeDataQuality(List<SensorSample> samples, int durationMs);
```

Implementation:
- `sampleRateHz = samples.length / (durationMs / 1000)`
- `gpsCoveragePercent = (samples where gpsSpeed != null).count / samples.length * 100`
- `headingLockedPercent`: samples with non-null `forwardAccel` after the first non-null sample (proxy for "heading was locked at this point"). Document the proxy in code.
- `overall`: minimum of the three grades using thresholds from the Decisions section above.

### D. Data-quality widget
File: `lib/screens/recording_detail/recording_detail_screen.dart`

1. Compute `DataQuality` once after `_load`.
2. Render a `_DataQualityBadge` widget below the summary cards: a small chip with an icon + label per metric, coloured by grade. Tooltip explains thresholds.
3. Hide the badge for recordings older than schema v3 if any required field is universally null (graceful degradation).

### E. Tests for the helper and widget
1. `test/services/data_quality_test.dart`:
   - Empty samples → all grades red, sampleRate 0.
   - 50 Hz, full GPS, full heading lock → all green.
   - Boundary cases at each threshold.
2. `test/screens/recording_detail_screen_test.dart` extension:
   - Renders the badge with correct labels for a green-grade fixture.

### F. Verify
- `flutter analyze` — clean
- `flutter test` — all green (5 scenarios + helper tests + widget test all pass; if any scenario surfaces a real bug, see step B's escalation)

### G. Wiki updates
- `.wiki/concepts/acceleration-calculation.md` — add a new section "Validation" describing the synthetic-input harness and the five scenarios.
- `.wiki/features/recording-history.md` — document the data-quality badge on the detail screen.
- `.wiki/conventions.md` — under "Testing", add a one-liner pointing to `test/scenarios/` for end-to-end pipeline validation.
- `.wiki/log.md` — append dated entry summarising scenarios and any bugs surfaced.

## Acceptance criteria

- 5 scenario tests in `test/scenarios/` pass (or scenario failures surfaced to user with specifics)
- `lib/services/data_quality.dart` exists with computed metrics + grades
- Recording detail screen shows a Data Quality badge
- All tests green; analyzer clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/concepts/acceleration-calculation.md`
- `.wiki/features/recording-history.md`
- `.wiki/conventions.md`
- `.wiki/log.md` (append entry)
