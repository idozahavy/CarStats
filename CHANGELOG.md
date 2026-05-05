# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Project README with feature list, build/test commands, signing instructions, and wiki pointer
- `CHANGELOG.md` (this file)
- GitHub Actions CI workflow at `.github/workflows/ci.yml` running `flutter analyze` and `flutter test` on every push to `main` and every pull request
- `flutter_launcher_icons` dev dependency and `assets/icon/` placeholder for Android + iOS launcher icons
- `android/key.properties.template` and commented release-signing block in `android/app/build.gradle.kts` for opt-in upload-key signing

## [0.1.0] - 2026-05-05

### Added

- Recording engine: 5 s gravity calibration followed by ~50 Hz sensor + 1 Hz GPS sampling, batch-inserted to SQLite every 2 s
- Acceleration math: complementary-filter gravity tracking, GPS-heading-based decomposition into forward / lateral / vertical, heading auto-calibration
- Two-table Drift schema (Recordings + SensorSamples) at `lib/data/database/database.dart` with additive migrations through schema v5
- Home screen with start-recording dialog (custom run name, 1–200 char validation)
- Recording screen: live cards (Speed, forward Acceleration, Pitch, Roll, peaks), heading-lock indicator, live chart
- Recording detail screen: summary cards, Speed-vs-Time, Accel-vs-Time, Speed-vs-Accel charts (uncurved, fixed Y bounds), data-quality badge, benchmarks section
- Recordings list with All / Dev / User filter chips, multi-select via long-press, Compare action enabled at exactly two selections, per-tile rename / delete popup
- Comparison screen: overlays two recordings on shared time axes, aligned at first movement (≥ 1 km/h), with auto-scaled Y axis
- Benchmarks: 0–100 km/h, 0–60 mph, 80–120 km/h, ¼ mile (with sub-sample-precision crossing), max forward G per 20 km/h speed bucket, sudden-acceleration response detection from cruise
- Session metadata: per-recording car / drive-mode / passengers / fuel / tyre / weather, with reusable car profiles managed from Settings → Vehicles → My Cars
- Versioned export / import: CSV + JSON export (save-to-file or system share-sheet), JSON import accepting `exportVersion` 1–2; v2 carries optional `carProfile` and `metadata` blocks
- Settings screen: theme mode (System / Light / Dark), language (System / English / עברית), dev-mode toggle, vehicles section, all persisted via SharedPreferences
- Localization scaffolding: ARB-based en + he with automatic Material RTL flip; units (km/h, g, m/s, °, hPa) intentionally untranslated
- Synthetic-input scenario harness in `test/scenarios/` covering acceleration, hard brake, heading-lock convergence, sample rate, GPS dropout
- Data-quality service grading sample rate, GPS coverage, and heading-locked percent with green/amber/red thresholds
- Android: `ForegroundNotificationConfig` for GPS streaming with screen off; foreground-service permissions in `AndroidManifest.xml`
- iOS: `AppleSettings(activityType: otherNavigation, allowBackgroundLocationUpdates: true, ...)` plus `UIBackgroundModes = [location]` for screen-locked recording

### Changed

- `RecordingEngine.lastWarning` retyped from `String?` to a `RecordingWarning` enum so services no longer hold English copy
- Charts: all four `LineChartBarData.isCurved` flags switched to `false` to remove phantom oscillations between samples; fixed Y bounds (±1.5 g for accel, 0 to 50-km/h-snapped max for speed)
- Recording-list long-press behaviour switched from rename-on-long-press to multi-select entry; rename + delete moved to a per-tile 3-dot popup

### Fixed

- Heading sentinel filter: `RecordingEngine` now drops GPS headings outside `[0, 360]` (geolocator emits `-1` when stationary) before they corrupt the decomposer
- Mid-recording GPS service loss: engine listens to `GpsService.serviceLost`, calls `stopRecording()` to flush, and surfaces a `SnackBar`
- `_AccelStatsAppState.dispose()` now closes the `AppDatabase`

### Removed

- Unused `linearAccelMagnitude` field from `RecordingSnapshot` (computed but never rendered)
- Unused `uuid` and `permission_handler` dependencies from `pubspec.yaml`
