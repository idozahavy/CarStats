# Recording

> Captures a single driving session: 5 s calibration countdown, then continuous sensor + GPS sampling while computing forward / lateral acceleration live.

**Scope:** [lib/screens/home/home_screen.dart](lib/screens/home/home_screen.dart), [lib/screens/recording/recording_screen.dart](lib/screens/recording/recording_screen.dart), [lib/services/recording_engine.dart](lib/services/recording_engine.dart), [lib/services/sensor_service.dart](lib/services/sensor_service.dart), [lib/services/gps_service.dart](lib/services/gps_service.dart), [lib/services/calibration_service.dart](lib/services/calibration_service.dart), [lib/widgets/name_dialog.dart](lib/widgets/name_dialog.dart)
**Last verified:** 2026-05-02 (phase 04)

---

## Summary

A recording runs in three engine states: `calibrating` → `recording` → `stopped` (or back to `idle` if stopped before calibration ends).

## User-facing behavior

- Home screen: *Start Recording* button → opens a name-picker dialog (default `Run <yyyy-MM-dd HH:mm>`, editable, 1–200 chars). *Start* navigates to the recording screen; *Cancel* aborts and the engine stays in `idle`.
- Recording screen:
  - During calibration, shows a 5 → 0 countdown.
  - Live cards: speed (km/h), forward acceleration (g), phone pitch and roll (°), and peak forward / brake / lateral (g).
  - Heading-lock indicator: `Calibrating heading...` until the horizontal offset is learned, then `Heading locked`.
  - Live speed-vs-accel chart (throttled to ~10 Hz).
  - *Close* (X) button stops recording and returns home.
- Recording is persisted as a `Recordings` row flagged `isDevRecording = devMode` (dev-mode is only consumed at recording-create time, not in the live UI).

## Data flow

1. `HomeScreen._startRecording` shows `showNameDialog` (from `lib/widgets/name_dialog.dart`). On confirm, reads `SettingsProvider.devMode` and calls `RecordingEngine.startRecording(name, isDev)`. On cancel, returns without starting.
2. Engine state → `calibrating`. `SensorService` + `GpsService` start. An accelerometer subscription feeds `CalibrationService`.
3. Countdown timer ticks every second. Reaching 0 calls `_finishCalibration`:
   - `CalibrationService.compute()` averages accelerometer samples → `CalibrationResult` (gravity vector + rotation matrix).
   - An `AccelerationDecomposer` is built from that result.
   - A `Recordings` row is inserted; `_currentRecordingId` is saved.
   - Engine state → `recording`. All sample streams are subscribed.
4. Per accel sample: `_decomposer.correctWithAccel` (complementary-filter gravity drift correction) → `_assembleSample()` builds a `SensorSamplesCompanion` and appends to `_sampleBuffer`.
5. Per gyro sample: `_decomposer.updateWithGyro(dt)` integrates angular velocity (Rodrigues) to track orientation changes.
6. Per GPS reading: bearing is computed from previous → current point (haversine). When speed ≥ `gpsMinSpeedForHeading` (2 m/s), `_decomposer.gpsHeadingRad` is updated and a speed delta is fed to the heading auto-calibrator.
7. Flush timer fires every 2 s → batch insert buffered samples.
8. On *stop*: cancel subscriptions, flush buffer, update `endedAt` + `durationMs`. If calibration never produced a recording row, engine returns to `idle` instead of `stopped`.

## Sensor sampling rates

| Stream | Rate |
|---|---|
| Accelerometer (raw) | 50 Hz (`samplingPeriod = 20 ms`) |
| User accelerometer (linear) | 50 Hz |
| Gyroscope | 50 Hz |
| Barometer | 1 Hz |
| GPS | ~1 Hz (driven by `bestForNavigation` accuracy) |

## Business rules

- Engine guards against re-entry: `startRecording` is a no-op unless state is `idle`; state flips to `calibrating` immediately to prevent rapid double-taps.
- If the user stops during calibration, no `Recordings` row is written (the `_finishCalibration` path rolls back by deleting the just-inserted row if state changed mid-await).
- Stationary clamp: when GPS speed < 0.5 m/s, displayed speed is 0 and |accel| < 0.05 g also snaps to 0.
- Peak G values are tracked across the session: forward (max positive), brake (min negative), lateral (max absolute).
- Live chart buffer is capped at 3000 snapshots (oldest dropped).
- UI is rebuilt at most every 100 ms regardless of incoming sensor rate.
- Live chart uses fixed bounds: `minX: 0, maxX: 300` km/h and `minY: -1.5, maxY: 1.5` g. Lines are not curve-smoothed (`isCurved: false`) so the chart faithfully reflects the noisy 50 Hz samples without phantom oscillations between points.

## Gotchas

- GPS heading from the OS is unreliable below ~2 m/s; the engine deliberately only feeds it into the decomposer above that threshold.
- GPS heading sentinel filtering: geolocator may emit `heading < 0` (or out of `[0, 360]`) when the device is stationary or has no compass fix. `RecordingEngine._onRecordingGps` drops those readings before they reach the decomposer or heading auto-calibrator, keeping the heading lock truthful.
- Mid-recording GPS loss: if location permission is revoked or the system service is disabled while recording, `GpsService` surfaces the stream error via its `serviceLost` broadcast stream. `RecordingEngine` listens, calls `stopRecording()` so already-buffered samples are flushed and `endedAt`/`durationMs` are written, sets `lastWarning = "GPS permission lost — recording saved early."`, and the recording screen surfaces it as a `SnackBar` (then calls `clearLastWarning`).
- iOS background location: `GpsService.startListening` uses `AppleSettings` with `pauseLocationUpdatesAutomatically: false` and `activityType: ActivityType.otherNavigation` so screen-lock does not kill the GPS stream. `Info.plist` declares `UIBackgroundModes = [location]` plus the two `NSLocation*UsageDescription` keys.
- Barometer is optional — `sensors_plus` errors are swallowed, `pressure` will stay null on devices without one.
- `_recordingStartTime` is the wall-clock time set when the `Recordings` row is inserted — not when calibration started. `timestampUs` on samples is therefore measured from end-of-calibration.
- The `Recordings` row is created **before** the state flips to `recording`; if the user closes mid-`await`, `RecordingEngine._finishCalibration` detects the state change and deletes the orphan row.
- On Android, a persistent notification is shown while GPS is streaming (required for background location). Configured in `GpsService.startListening` via `ForegroundNotificationConfig`.

## Status

Complete (MVP).

## Related pages

- [acceleration-calculation](../concepts/acceleration-calculation.md) — math behind forward/lateral decomposition
- [data-model](../data-model.md) — where samples land
- [recording-history](recording-history.md) — post-session review
- [settings](settings.md) — dev-mode toggle
