# Phase 03 — Charts Polish & Flaky-Test Investigation

## Goal
Make the charts faithful to the underlying noisy 50 Hz data (no curve smoothing artifacts), and investigate why some screen tests log the same test name many times in succession (suggesting framework retries or pump loops).

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: `.wiki/index.md`, `.wiki/features/recording.md`, `.wiki/features/recording-history.md`.

**Code layout**:
- `lib/screens/recording/recording_screen.dart` — live chart `_LiveChart`
- `lib/screens/recording_detail/recording_detail_screen.dart` — `_SpeedAccelChart`, `_AccelTimeChart`, `_SpeedTimeChart`
- `lib/core/chart_utils.dart` — `downsample()` helper
- `test/screens/` — widget tests

## Scope

**In:**
- Disable `isCurved: true` on raw-sample charts (or replace with a real low-pass filter)
- Investigate the test-name repetition pattern in screen tests
- Bound chart Y-axis sensibly so noise spikes do not blow out scale
- Wiki updates

**Out:**
- New chart types
- Live-chart performance refactor
- Anything that changes recorded data

## Tasks (ordered)

### A. Curve smoothing
1. In `lib/screens/recording/recording_screen.dart` (`_LiveChart`) and all three charts in `lib/screens/recording_detail/recording_detail_screen.dart`, change `isCurved: true` to `isCurved: false`. Curve smoothing on noisy 50 Hz acceleration creates phantom oscillations between real samples.
2. Keep `dotData: const FlDotData(show: false)` and `barWidth: 2`. No other styling changes.

### B. Y-axis bounds
1. For `_AccelTimeChart` (acceleration over time), set `minY: -1.5` and `maxY: 1.5` on `LineChartData`. Most car g-forces sit within ±1 g; capping prevents a single noise spike from rescaling the whole chart.
2. For `_SpeedTimeChart`, set `minY: 0` and `maxY` to `((maxObservedSpeed / 50).ceil() * 50).toDouble().clamp(50, 400)` so the scale snaps to round numbers.
3. For `_SpeedAccelChart` (speed vs accel scatter-line), do not constrain bounds — the data drives the shape.
4. For `_LiveChart` (speed vs accel during recording), set `minX: 0`, `maxX: 300`, `minY: -1.5`, `maxY: 1.5`.

### C. Flaky-test investigation
The test runner output shows lines like `+5: ... RecordingScreen shows live stats after calibration` repeating with incrementing counts before moving on. This indicates either `pumpAndSettle` retry loops or that the same test counts toward multiple groups.

1. Read `test/helpers/pump_app.dart` and `test/screens/recording_screen_test.dart`.
2. Identify whether the pattern is from:
   - `tester.pumpAndSettle()` exceeding default timeout and retrying
   - Multiple `expect` calls inside one test where each expect causes a pump
   - Actual test duplication
3. **Do NOT change any test that currently passes.** If the pattern is benign (just verbose runner output), document it in the wiki under conventions and stop. If it is a real timeout-retry loop, replace the offending `pumpAndSettle()` with bounded `pump(Duration)` calls or `pumpAndSettle(Duration(seconds: 2))`.
4. Run `flutter test --reporter expanded` to confirm whether the issue persists.

### D. Verify
- `flutter analyze` — clean
- `flutter test` — all green
- Visually verify on the running app: charts no longer show smooth curves between data points.

### E. Wiki updates
- `.wiki/features/recording.md` — note Y-axis bounds for the live chart; remove any mention of curve smoothing if present.
- `.wiki/features/recording-history.md` — note Y-axis bounds for the detail-screen charts.
- `.wiki/conventions.md` — under "Testing", add a one-line note about screen-test pump strategy if you changed any test or documented the pattern.
- `.wiki/log.md` — append dated entry.

## Acceptance criteria

- All four chart `isCurved` flags are `false`
- `_AccelTimeChart` and `_LiveChart` have `minY: -1.5, maxY: 1.5`
- `_SpeedTimeChart` Y-axis snaps to round 50 km/h increments
- `flutter analyze` clean; `flutter test` green
- Wiki notes the chart bounds and the test-pattern finding (whether benign or fixed)

## Wiki updates required

- `.wiki/features/recording.md`
- `.wiki/features/recording-history.md`
- `.wiki/conventions.md` (only if a test was changed or pattern documented)
- `.wiki/log.md` (append entry)
