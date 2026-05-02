# Wiki Log

> Append-only record. Most recent entries at the bottom.

## [2026-04-18] build | Initial wiki generation
Pages created:
- architecture.md
- data-model.md
- stack.md
- conventions.md
- features/recording.md
- features/recording-history.md
- features/export-import.md
- features/settings.md
- features/benchmarks.md (planned)
- features/overlay-comparison.md (planned)
- features/session-metadata.md (planned)
- concepts/acceleration-calculation.md
- concepts/state-management.md
- index.md

Source: built from codebase + idea.md (subsequently deleted, content absorbed).

Logical errors corrected vs. idea.md:
- Quaternion/rotation-matrix storage was marked "Not Yet Implemented" in idea.md but is actually implemented (schema v3 `quat_w/x/y/z`, populated per sample by `RecordingEngine._assembleSample`). Moved to the recording feature page as implemented behaviour.
- idea.md described the 5 s countdown as sampling gravity **and** gyroscope. Actual `CalibrationService` only averages accelerometer readings; gyroscope is used for mid-recording orientation tracking, not calibration. Corrected in the acceleration-calculation concept page.
- idea.md said "JSON export" — both CSV export and JSON import exist too. Corrected in stack.md and features/export-import.md.
- idea.md described "User Recording" as a reduced data shape. Actual schema is identical for dev and user recordings; `isDevRecording` is only a filter flag. Corrected in data-model.md and features/recording-history.md.

## [2026-04-21] lint | Full-wiki source verification + schema normalisation

Drift fixed:
- features/recording.md — live cards list corrected: actual UI shows Speed, forward Acceleration, Pitch, Roll, and the Peak trio, plus a heading-lock indicator. The prior "lateral accel live card" and "dev-mode shows linear-accel magnitude" claims were wrong — `linearAccelMagnitude` is computed but never rendered.
- features/settings.md — consumer list corrected: only `HomeScreen._startRecording` reads live `SettingsProvider.devMode`. The "Dev" filter chip in `RecordingsScreen` reads the persisted `Recordings.isDevRecording` column, not the live setting.
- data-model.md — added missing `AppDatabase.getRecording` row to the Access patterns table.

Structural:
- SCHEMA.md — moved "API endpoints" from required to optional (conditional on the feature exposing an API). Added planned-feature guidance: keep the standard shape, mark unknown sections with `_TBD._`.
- All pages — title promoted to H1 and subsections to H2 (were all H3). `index.md`/`log.md` unchanged.
- features/benchmarks.md, features/overlay-comparison.md, features/session-metadata.md — rewritten to the standard feature-page shape with `_TBD._` markers for undecided details.
- concepts/state-management.md — `Scope` expanded to include `lib/data/database/database.dart` (file hosts `RecordingStore` which the page discusses).
- All prose line-number anchors (`lib/main.dart#L79`, `recording_engine.dart#L215-L218`, `gps_service.dart#L55`, `export_service.dart#L36`) replaced with symbol names (`_PermissionGate`, `_finishCalibration`, `GpsService.startListening`, `ExportService.exportRecording`).
- concepts/acceleration-calculation.md — escaped `|accel|` in GPS-thresholds table (broke the column count).

Maintenance:
- `Last verified` bumped to 2026-04-21 on every page.
- Removed the magnetometer carve-out from the 2026-04-18 build entry (feature was never implemented and does not merit a wiki footprint).

No `[FLABBERGASTED]` markers outstanding. No broken cross-references found.

## [2026-05-02] cleanup | Phase 01 — dead code & unused deps removed

- Removed `linearAccelMagnitude` from RecordingSnapshot (computed but never rendered).
- Removed unused dependencies `uuid`, `permission_handler` from pubspec.yaml.
- `_AccelStatsAppState.dispose()` now closes the AppDatabase.

## [2026-05-02] update | Phase 02 — robustness pass

- Versioned JSON export: `ExportService` now writes `"exportVersion": 1` as the first key of the JSON root. Import rejects missing/wrong version with `FormatException` and validates the presence of `recording` + `samples` keys before casting. New `importRecordingFromJson(db, jsonString)` is the testable entry point; the picker-driven `importRecording` is a thin wrapper.
- GPS heading sentinel filter: `RecordingEngine._onRecordingGps` now drops headings outside `[0, 360]` (geolocator emits `-1` when stationary / no compass fix) before they can corrupt the decomposer or heading auto-calibrator.
- Mid-recording permission loss: `GpsService` exposes a `serviceLost` broadcast stream fed by the position stream's `onError`. `RecordingEngine` listens, calls `stopRecording()` (flushes buffered samples and writes `endedAt`/`durationMs`), and sets `lastWarning`. The recording screen surfaces `lastWarning` via SnackBar then calls `clearLastWarning`.
- iOS background location: `GpsService.startListening` now uses `AppleSettings(activityType: otherNavigation, pauseLocationUpdatesAutomatically: false, allowBackgroundLocationUpdates: true, showBackgroundLocationIndicator: true)` so screen-lock does not kill the GPS stream. Added `UIBackgroundModes = [location]` to `ios/Runner/Info.plist`.
- Tests: new `test/services/export_import_test.dart` covers round-trip + three rejection cases; `test/services/recording_engine_test.dart` extended with a heading-sentinel test.

## [2026-05-02] update | Phase 03 — charts polish + flaky-test investigation

- All four chart `LineChartBarData.isCurved` flags flipped from `true` to `false` (live chart in `recording_screen.dart`; `_SpeedAccelChart`, `_AccelTimeChart`, `_SpeedTimeChart` in `recording_detail_screen.dart`). Curve smoothing on noisy 50 Hz acceleration produced phantom oscillations between real samples.
- Y-axis bounds added: `_LiveChart` (`minX: 0, maxX: 300, minY: -1.5, maxY: 1.5`), `_AccelTimeChart` (`minY: -1.5, maxY: 1.5`), `_SpeedTimeChart` (`minY: 0`, `maxY` snaps to the next 50 km/h, clamped to `[50, 400]`). `_SpeedAccelChart` remains unconstrained — data drives the shape.
- Flaky-test investigation: the test runner showed the same test name on multiple consecutive `+N:` lines under `--reporter expanded`. Investigation confirmed it is benign — Flutter test runs files in parallel, the cumulative pass counter ticks for *any* file completing, and the reporter just refreshes the displayed name. `pumpAndSettle()` calls all complete fast and no test was modified. Documented under `conventions.md → Testing`.
- `flutter analyze`: clean. `flutter test`: 78 tests passed.
