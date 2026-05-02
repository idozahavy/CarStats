# Phase 02 — Robustness Pass

## Goal
Harden the recording and import pipelines against real-world failure modes: malformed import files, GPS heading sentinels, permission revocation mid-recording, and iOS background screen-lock killing GPS.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/architecture.md`, `.wiki/features/recording.md`, `.wiki/features/export-import.md`.

**Code layout**:
- `lib/main.dart` — bootstrap, providers, `_PermissionGate`
- `lib/services/recording_engine.dart` — orchestration
- `lib/services/gps_service.dart` — geolocator wrapper
- `lib/services/sensor_service.dart` — sensors_plus wrapper
- `lib/services/export_service.dart` — CSV/JSON export + JSON import
- `test/services/`, `test/screens/`, `test/helpers/`

**Hard rules**:
- Read a file before modifying it.
- After schema edits run `dart run build_runner build --delete-conflicting-outputs` (no schema edits expected this phase).
- Update wiki per `.wiki/SCHEMA.md`.
- Never throw uncaught — surface failures via `SnackBar`, matching existing convention.

## Decisions already made (do not relitigate)

- **Export version field**: add `"exportVersion": 1` at the JSON root. Import rejects if the field is missing or its value is not `1`, with a user-facing error.
- **Permission revoked mid-recording**: stop AND save what was captured up to that point. Show a SnackBar warning the user.
- **iOS background location**: enable `pauseLocationUpdatesAutomatically: false` and `activityType: ActivityType.otherNavigation` so screen-lock does not kill recording.

## Scope

**In:**
- Versioned JSON export + validating import
- GPS heading sentinel handling (negative / -1 when stationary)
- Mid-recording permission/service-loss detection → graceful stop + save
- iOS background-location flags
- Tests for each of the above

**Out:**
- Android signing
- New UI screens (only minimal SnackBars)
- Schema changes
- Anything in the planned-features wiki pages

## Tasks (ordered)

### A. Versioned export + validating import
File: `lib/services/export_service.dart`

1. Add `static const int exportVersion = 1;` constant.
2. In `_toJson`, add `'exportVersion': exportVersion` as the first key of the root map. CSV is unchanged (no version row needed).
3. In `importRecording`:
   - After `jsonDecode`, verify `data['exportVersion']` equals `exportVersion`. If missing or different, throw a `FormatException` with a clear message: `"Unsupported export version: <found>. Expected: <expected>."`
   - Wrap the entire `importRecording` body in try/rethrow only at the boundary — the call site at `lib/screens/recordings/recordings_screen.dart::_importRecording` already shows a SnackBar on exception, which will surface this.
4. Verify `recording` and `samples` keys exist before casting; if either is missing, throw `FormatException("Malformed export: missing 'recording' or 'samples'")`.

### B. GPS heading sentinel
File: `lib/services/recording_engine.dart`

1. In `_onRecordingGps`, before using `r.heading`:
   - If `r.heading < 0` or `r.heading > 360`, treat the heading as unavailable (do not feed it to the decomposer for this tick, do not call `_headingCalibrator` for this tick).
2. Also in `lib/services/gps_service.dart`, normalise: in the stream listener, if `position.heading` is negative replace with `0.0` AND set a new `headingValid: false` flag — but the simpler fix is to leave the raw value and filter inside the engine. **Choose engine-side filtering to keep `GpsReading` truthful.**

### C. Permission / service loss mid-recording
File: `lib/services/recording_engine.dart` plus `lib/services/gps_service.dart`

1. In `GpsService`, register an `onError` on the position stream subscription. When the error fires (revocation surfaces as a stream error in geolocator), emit a sentinel via a new `Stream<void> get serviceLost` broadcast stream.
2. In `RecordingEngine._finishCalibration`, subscribe to `_gpsService.serviceLost`. Handler: call `stopRecording()` and set a `String? lastWarning` field on the engine to `"GPS permission lost — recording saved early."` Notify listeners.
3. The recording screen already calls `Consumer<RecordingEngine>` — surface `lastWarning` via a SnackBar when it becomes non-null. Clear `lastWarning` after showing.
4. **Do NOT discard captured data** — `stopRecording()` already flushes the buffer and updates `endedAt` when `_currentRecordingId` is set. Confirm this path runs.

### D. iOS background location
File: `lib/services/gps_service.dart`

1. The current `else` branch of `defaultTargetPlatform == TargetPlatform.android` builds a generic `LocationSettings`. Split the iOS case explicitly and use `AppleSettings`:
   ```dart
   locationSettings = AppleSettings(
     accuracy: LocationAccuracy.bestForNavigation,
     activityType: ActivityType.otherNavigation,
     distanceFilter: 0,
     pauseLocationUpdatesAutomatically: false,
     showBackgroundLocationIndicator: true,
     allowBackgroundLocationUpdates: true,
   );
   ```
2. Verify `ios/Runner/Info.plist` declares:
   - `NSLocationWhenInUseUsageDescription`
   - `NSLocationAlwaysAndWhenInUseUsageDescription`
   - `UIBackgroundModes` includes `location`
   If any is missing, add it. If you cannot read/write `Info.plist`, surface to user.

### E. Tests

1. `test/services/export_import_test.dart` (new file):
   - Round-trip: export a known recording → re-import → assert recording + sample fields match (use the existing fakes in `test/helpers/fakes.dart`).
   - Import a JSON without `exportVersion` → expect `FormatException`.
   - Import a JSON with `exportVersion: 999` → expect `FormatException`.
   - Import a JSON missing `samples` key → expect `FormatException`.
2. `test/services/recording_engine_test.dart` extension:
   - Add a test that simulates a GPS reading with `heading: -1` and asserts the decomposer's `gpsHeadingRad` was NOT updated and `_headingCalibrator` did not receive a sample.
3. Skip iOS background-location runtime tests — flag-only changes verified manually on device.

### F. Verify
- `flutter analyze` — clean
- `flutter test` — all green

### G. Wiki updates
- `.wiki/features/export-import.md` — document `exportVersion` field and import validation behavior. Bump `Last verified`.
- `.wiki/features/recording.md` — note the GPS-heading-sentinel filter and permission-loss auto-stop behavior. Bump `Last verified`.
- `.wiki/conventions.md` — under "Error handling", add: "Import failures and mid-recording permission loss surface as SnackBar messages; recording always saves what was captured."
- `.wiki/log.md` — append dated entry summarising A–D.

## Acceptance criteria

- JSON export contains `"exportVersion": 1` at root
- Import rejects missing/wrong version with a clear FormatException; SnackBar appears in the UI
- GPS readings with heading < 0 or > 360 do not corrupt the heading calibrator
- Revoking location during recording stops the engine, saves captured samples, and shows a SnackBar warning
- iOS `LocationSettings` is `AppleSettings` with `pauseLocationUpdatesAutomatically: false` and `activityType: otherNavigation`
- `Info.plist` includes the three required keys
- All new tests pass; existing tests still pass; `flutter analyze` clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/features/export-import.md`
- `.wiki/features/recording.md`
- `.wiki/conventions.md`
- `.wiki/log.md` (append entry)
