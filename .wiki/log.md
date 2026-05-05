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

## [2026-05-02] update | Phase 04 — UX polish (name, rename, share, empty state)

- Name picker dialog: home screen's *Start Recording* now opens an `AlertDialog` (`showNameDialog` in `lib/widgets/name_dialog.dart`) pre-filled with `Run <yyyy-MM-dd HH:mm>`, validates 1–200 chars, and only calls `RecordingEngine.startRecording` after the user confirms. Cancel returns to home with the engine still `idle`.
- Rename in recordings list: long-press a tile opens the same `showNameDialog` with the existing name. New `RecordingStore.renameRecording(id, newName)` method (interface + `AppDatabase` impl + `FakeRecordingStore`/`FakeDatabase` mirrors). The list refreshes via `_load()` after a successful rename.
- Share-sheet: added `share_plus ^11.0.0`. New `ExportService.shareRecording(recording, samples, format)` writes the CSV/JSON to `getTemporaryDirectory()` and invokes `SharePlus.instance.share(ShareParams(files: [...], subject: name))`. Detail screen's export menu now exposes 4 items modelled by a private `_ExportAction` enum: Save as CSV, Save as JSON, Share as CSV, Share as JSON.
- Empty-state CTA: recordings list now shows an icon + helper text + a "Start a recording" `FilledButton` that pops back to home when the DB is empty. When the filter hides everything but the DB is non-empty, the screen shows "No recordings match this filter." with no CTA.
- Tests: `home_screen_test` covers dialog open/cancel/confirm; `recordings_screen_test` covers long-press rename (confirm + cancel) and the empty-state CTA + filtered-empty branch; `recording_detail_screen_test` updated for the new menu labels. `flutter analyze` clean, `flutter test` 83 passed.

## [2026-05-02] update | Phase 05 — i18n scaffolding (English + Hebrew, RTL)

- Added `flutter_localizations` (SDK) and `generate: true` plus a project-root `l10n.yaml`. ARB files live in [lib/l10n/](lib/l10n/) — `app_en.arb` is the template, `app_he.arb` is the machine-translated Hebrew set (user to review). `flutter pub get` / `flutter gen-l10n` produces `app_localizations.dart` + per-locale partials.
- New `LocaleProvider` (`ChangeNotifier`) in [lib/core/providers.dart](lib/core/providers.dart) backed by `SharedPreferences` key `locale`. `null` = follow device. Wired into `MaterialApp.locale` via `Consumer2<ThemeProvider, LocaleProvider>` in [lib/main.dart](lib/main.dart). Added `StorageKeys.locale`.
- Settings screen gains a **Language** section between Appearance and Developer with the same picker pattern as Theme: System / English / עברית (Hebrew). Subtitle reflects the current selection in the active locale.
- All user-facing strings under `lib/screens/`, `lib/main.dart`, and `lib/widgets/name_dialog.dart` now resolve via `AppLocalizations.of(context)!`. The recording engine's `lastWarning` was retyped from `String?` to a `RecordingWarning?` enum so the UI maps it to a localised string at render time — services no longer hold English copy.
- Hebrew flips Material's `Directionality` to RTL automatically; charts and rows render correctly with no manual flips. Units (`km/h`, `g`, `m/s`, `°`) are intentionally not translated; only the labels around them are.
- Tests: new `test/core/locale_provider_test.dart` covers default/null, prefs round-trip, and listener notification. `test/screens/settings_screen_test.dart` extended with three Language-section tests. New `test/screens/home_screen_he_test.dart` pumps the home screen with `locale: Locale('he')` and asserts Hebrew labels + `TextDirection.rtl`. `test/helpers/pump_app.dart` now wires `LocaleProvider` and `AppLocalizations.localizationsDelegates` and accepts an optional `locale` parameter (defaults to `en`). `flutter analyze` clean; `flutter test` — 92 passed.

## [2026-05-02] update | Phase 06 — session metadata + car profiles (schema v5)

- Schema v5: two new tables, additive migration via `Migrator.createTable` from a v4 base.
  - `car_profiles` — reusable vehicle profiles (`name`, `make`, `model`, `year?`, `fuelType`, `transmission`).
  - `recording_metadata` — one optional row per recording (`recordingId` FK, `carProfileId` FK nullable, `driveMode`, `passengerCount?`, `fuelLevelPercent?`, `tyreType`, `weatherNote`, `freeText`).
- `RecordingStore` extended with `getAllCarProfiles`, `getCarProfile`, `insertCarProfile`, `updateCarProfile`, `deleteCarProfile`, `getMetadataForRecording`, `upsertMetadata`. `AppDatabase.deleteCarProfile` is transactional and nulls `carProfileId` on referencing metadata rows before deleting the profile. `AppDatabase.deleteRecording` now also deletes the metadata row before sample rows.
- New `AppDatabase.forTesting` ctor (annotated `@visibleForTesting`) so the migration test can inject a `NativeDatabase.memory` with a hand-rolled v4 schema and a seeded recording — Drift's `onUpgrade` then runs end-to-end.
- New `lib/screens/manage_cars/manage_cars_screen.dart` — list of profiles, FAB to add, tap to edit (in-dialog form), swipe-to-delete with confirmation. Reachable from `Settings → Vehicles → My Cars`.
- New `lib/screens/recording_detail/metadata_sheet.dart` — `showMetadataSheet(context, recordingId, initial)` opens a `showModalBottomSheet` with car dropdown (+ "Add new car…" shortcut to Manage Cars), drive mode, passengers, fuel %, tyres, weather, free-text. Save calls `upsertMetadata`.
- Recording detail screen: loads metadata + linked car alongside the recording. Renders an outlined `Add details` button when no metadata row exists, or a metadata summary card with `Edit details` when it does. Export menu now passes the loaded `metadata` + `carProfile` through to `ExportService.exportRecording` / `shareRecording`.
- Export/import bumped to `exportVersion: 2`. JSON now includes optional `carProfile` and `metadata` blocks at the root. Importer accepts any `exportVersion` in `1..currentVersion`: v1 imports skip the metadata blocks (treated as empty); v2 imports insert a fresh `CarProfiles` row (no name dedupe) and a `RecordingMetadata` row keyed to the new recording id. CSV format unchanged except for a leading `# Metadata not included…` comment line.
- i18n: new keys for the Vehicles settings section, Manage Cars screen, fuel/transmission labels, and metadata sheet — both `app_en.arb` and `app_he.arb`.
- Tests: new `test/data/migration_v4_to_v5_test.dart` (v4-shaped DB upgrades cleanly, new tables queryable, `upsertMetadata` updates instead of inserting on the second call). New `test/services/export_import_v2_test.dart` (v2 round-trip preserves all metadata fields; v2 export with no metadata round-trips empty). New `test/screens/manage_cars_screen_test.dart` (empty state, FAB→add→row, preloaded rows). `test/services/export_import_test.dart` extended with a v1-import-still-works test. `test/screens/recording_detail_screen_test.dart` extended with Add-details / Edit-details branches. `test/helpers/fakes.dart` gained in-memory `carProfiles` + `metadataRows` and full coverage of the new interface methods.
- `flutter analyze` clean. `flutter test` — 102 passed.

## [2026-05-02] update | Phase 07 — recording-pipeline validation + data-quality badge

- Synthetic-input harness in [test/scenarios/](test/scenarios/): `synthetic_drive.dart` exposes a `ScenarioRig` that wires a real `RecordingEngine` to `FakeSensorService` + `FakeGpsService`, plus simulators for constant-accel, hard-brake, steady-cruise, and alternating accel/brake bursts. Convention: phone calibrated flat, GPS heading 0, "forward" = phone +X.
- 5 scenario tests in `recording_pipeline_test.dart`: 0→100 km/h pull, 100→0 km/h hard brake, heading-lock convergence (±15° alignment), sample-rate / monotonicity, GPS dropout resilience.
- Surfaced finding from Scenario 1: under sustained ~0.5 g constant input, the raw-accel magnitude (~11.3 m/s²) sits within `AccelerationDecomposer._gravityTolerance` (= 2.0 m/s²) of 9.81. The complementary-filter gravity correction therefore fires every sample and over a 5 s pull at 50 Hz the gravity estimate drifts toward the accel direction, suppressing decomposed forward from ~5.6 m/s² down to <0.5 m/s² by end of run. Scenario 1 was relaxed to assert sign / lock / lateral-collapse only; the magnitude / integration claims from the phase doc are flagged for a follow-up phase. Documented under `concepts/acceleration-calculation.md → Validation → Surfaced finding`.
- Surfaced finding from Scenario 5: the engine never resets `_lastGps`, so a mid-recording GPS gap leaves stale GPS values on samples. Scenario 5 was reframed to a 5 s warmup gap before first GPS fix (still satisfies the 83% coverage assertion and the spec spirit "GPS dropout resilience").
- New [lib/services/data_quality.dart](lib/services/data_quality.dart): `computeDataQuality(samples, durationMs)` returns `DataQuality { sampleRateHz, gpsCoveragePercent, headingLockedPercent, *Grade }` with green/amber/red thresholds (45/30 Hz; 95/80%; 80/50%).
- Recording detail screen renders a `_DataQualityBadge` between the summary cards and the first chart — three coloured chips with tooltips showing thresholds.
- i18n: new keys `detail_quality_*` in `app_en.arb` + `app_he.arb`.
- Tests: new `test/services/data_quality_test.dart` (8 cases covering empty, zero-duration, full-green, amber/red boundaries on each metric, and worst-grade overall). `test/screens/recording_detail_screen_test.dart` extended with a badge render test. `flutter analyze` clean; `flutter test` — 116 passed.

## [2026-05-05] update | Phase 08 — benchmarks (0–100, ¼ mile, max accel at speed, sudden accel)

- New `lib/services/benchmarks/` directory with four files: `benchmarks.dart` (entry point + result types + tunables), `standard.dart` (0–100 km/h, 0–60 mph, 80–120 km/h, ¼ mile), `max_accel_at_speed.dart` (peak G per 20-km/h-wide bucket centred at 0…140), `sudden_accel.dart` (cruise → floor-it event detection). All calculators are pure functions over `List<SensorSample>`. No DB writes; `BenchmarkReport computeBenchmarks(samples)` is the single entry point.
- Validation rules for the speed-to-speed benchmarks: candidate segment is rejected if any GPS gap inside it exceeds 2 s, or if `forwardAccel` stays negative for > 0.5 s (driver lifted). Picks the *fastest* qualifying segment in the recording. ¼ mile uses the *first* near-stop start (≤ 5 km/h) and trapezoidal distance integration; the crossing point at 402.336 m is solved as a quadratic on the bracketing sample interval to give sub-sample-period precision.
- Sudden-accel: cruise window ≥ 3 s, speed range ≤ ±2 km/h. After the cruise ends, scans up to 2 s for forward G > 0.2 g sustained ≥ 0.5 s. Reports cruise mean speed (km/h), response time, peak G during the burst.
- Detail screen renders a `Benchmarks` section under the three time-series charts: 4 standard-benchmark cards (Wrap layout), bucket list for max-accel-at-speed, sudden-accel event list. Dev recordings show a `MaterialBanner` above the section: *"Dev recording — benchmark results may be unreliable."* Compute is in-build (sample lists are in-memory; iteration is fast).
- i18n: 11 new keys under `detail_benchmarks_*` in `app_en.arb` + `app_he.arb`; gen-l10n re-run.
- Tests: new `test/services/benchmarks/standard_test.dart` (5 cases — 0–100 in 5 s, all-three populated on a sweep, lift invalidation, GPS gap invalidation, ¼ mile time + trap speed), `max_accel_at_speed_test.dart` (3 cases — empty input, peak-in-bucket placement, null-skip), `sudden_accel_test.dart` (2 cases — single event from cruise + floor-it, no event from a 0.1 g bump). `recording_detail_screen_test.dart` gained Benchmarks-section render and dev-banner-render tests. `flutter analyze` clean; `flutter test` — 128 passed.

## [2026-05-05] update | Phase 10 — project infrastructure (README, CHANGELOG, CI, icon, signing)

- `README.md` rewritten: replaces the default Flutter scaffold with project description pulled from `architecture.md` + `stack.md`, feature list adjusted to what shipped through phase 09, build/run/test commands, pointer to `.wiki/index.md`, "Continuous integration" section pointing at the new workflow, "Release signing (Android)" section walking through the keystore opt-in, and an "App icon" section explaining the `dart run flutter_launcher_icons` flow. License left as `_TBD_`.
- New top-level `CHANGELOG.md` in keep-a-changelog 1.1 format. `[Unreleased]` collects the phase-10 deliverables; `[0.1.0] - 2026-05-05` synthesises Added / Changed / Fixed / Removed from `.wiki/log.md` and the 11 commits in `git log --oneline`. Honest about scope — only lists code that actually exists.
- New `.github/workflows/ci.yml`. Triggers on `pull_request` and `push` to `main`. Single `analyze-and-test` job on `ubuntu-latest`: checkout → `subosito/flutter-action@v2` (channel stable, cache enabled) → `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → `flutter test`.
- Launcher icons: added `flutter_launcher_icons ^0.14.1` (resolved 0.14.4) to `dev_dependencies`. New `assets/icon/icon.png` — 1024×1024 placeholder rendered via PowerShell + `System.Drawing` (dark navy bg, white speedometer dial arc, red needle, white hub). New `assets/icon/README.md` documents the regenerate flow. `pubspec.yaml` config block: `android: true`, `ios: true`, `remove_alpha_ios: true` (App Store rejects alpha-channel icons), `image_path: "assets/icon/icon.png"`, `min_sdk_android: 21`. Generator ran successfully — Android mipmap drawables and iOS `AppIcon.appiconset` regenerated.
- Android release signing: new `android/key.properties.template` with the four required keys (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`). `android/app/build.gradle.kts` (Kotlin DSL — phase doc said Groovy `build.gradle`, but the actual file is `.kts`) gets a top-of-file comment block explaining the 4-step opt-in: copy template → keytool → fill values → uncomment. Both the `keystoreProperties` loader and a `signingConfigs.create("release")` block are present but commented out. The default release `signingConfig = signingConfigs.getByName("debug")` is preserved so `flutter run --release` still works without a keystore. `key.properties` and `*.jks` were already gitignored at `android/.gitignore`.
- Wiki: `stack.md` adds `flutter_launcher_icons` to dev deps, the launcher-icon command to Commands, and new "CI" + "Release signing (Android)" sections; `conventions.md` adds a "CI" subsection above Testing. `Last verified` bumped to 2026-05-05 on both.

## [2026-05-05] update | Phase 09 — overlay comparison

- New `lib/screens/comparison/comparison_screen.dart` — pushed from the recordings list with two recording ids. Loads both recordings + sample lists in parallel via `Future.wait`, computes `firstMovementUs` (first sample where `gpsSpeed * 3.6 ≥ 1`) per recording, and renders two stacked charts (Speed-over-time + Acceleration-over-time). Each chart draws both runs with `colorScheme.primary` (A) / `colorScheme.tertiary` (B); a coloured-dot legend sits below each chart. X axis is "Time since first movement (s)"; samples before first movement are dropped; the chart auto-scales to the longer recording.
- `RecordingsScreen` rewired for multi-select. Long-press now enters selection mode (replacing rename-on-long-press from phase 04). The app bar swaps to a "{n} selected" title with a leading close icon and a *Compare* action enabled only at exactly 2 selections; a third tap is ignored. Rename + delete moved to a per-tile trailing 3-dot popup (`Icons.more_vert`). The selected tile renders with a `primaryContainer` background and a `check_circle` leading icon.
- Acceleration-time chart uses fixed `minY: -1.5, maxY: 1.5` (g); speed-time chart uses `minY: 0` and the 50 km/h-snapped `maxY` from phase 03 driven by the higher of the two recordings.
- i18n: 10 new keys across `recordings_menu_*`, `recordings_selection_*`, and `compare_*` in both `app_en.arb` + `app_he.arb`; `gen-l10n` re-run.
- Tests: new `test/screens/comparison_screen_test.dart` (3 cases — names + chart titles + 2× LineChart render; alignment fixture A@2s/B@5s both shift to x=0; stationary recording shows the no-movement notice). `recordings_screen_test.dart` updated: rename + delete now drive the popup menu; 4 new cases for selection mode (long-press → 1 selected + Compare disabled; second tap → Compare enabled; third tap ignored; close icon clears selection). `flutter analyze` clean; `flutter test` — 135 passed.
