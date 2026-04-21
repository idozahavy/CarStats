# Data Model

> Two-table SQLite schema managed by Drift: one `Recordings` row per session, many `SensorSamples` rows per recording.

**Scope:** [lib/data/database/database.dart](lib/data/database/database.dart), [lib/data/database/database.g.dart](lib/data/database/database.g.dart)
**Last verified:** 2026-04-21

---

## Database

- Engine: SQLite via `drift` + `sqlite3_flutter_libs`.
- File: `accel_stats.sqlite` in the app documents directory. An older `car_stats.sqlite` is auto-renamed on first run.
- Access is abstracted behind `RecordingStore` (interface) so screens receive an interface, not the concrete `AppDatabase`.
- Singleton: `AppDatabase()` factory caches a single instance.

## Tables

### `Recordings`

| Column | Type | Notes |
|---|---|---|
| `id` | int, PK, autoincrement | |
| `name` | text, 1–200 chars | Free-text label (default `Run <timestamp>`) |
| `startedAt` | datetime | Set when the `Recordings` row is created, right after calibration ends |
| `endedAt` | datetime, nullable | Set on stop |
| `durationMs` | int, default 0 | Populated on stop |
| `isDevRecording` | bool, default false | Drives filter chips on the recordings list |
| `notes` | text, default '' | Reserved for future session metadata |

### `SensorSamples`

| Group | Columns | Notes |
|---|---|---|
| Identity | `id`, `recordingId` (FK → Recordings), `timestampUs` | `timestampUs` = µs since recording start |
| Raw accel | `accelX/Y/Z` | Nullable — accelerometer frame |
| Linear accel | `linearAccelX/Y/Z` | Platform sensor-fusion output (`TYPE_LINEAR_ACCELERATION` on Android) |
| Gyroscope | `gyroX/Y/Z` | rad/s |
| Computed | `forwardAccel`, `lateralAccel` | m/s², world-frame after decomposition |
| GPS | `gpsSpeed` (m/s), `gpsLat`, `gpsLon`, `gpsHeading`, `gpsAltitude`, `gpsAccuracy`, `gpsBearing` | `gpsBearing` is the bearing derived from the previous GPS point (haversine) |
| Gravity | `gravX/Y/Z` | Current gravity direction estimate in phone frame (Z row of the rotation matrix) |
| Barometer | `pressure` | hPa; nullable (sensor may be absent) |
| Orientation | `quatW/X/Y/Z` | Unit quaternion of the world-from-phone rotation |

All sensor columns are nullable — any sensor may drop samples, and GPS is absent until the first fix.

## Access patterns

| Operation | Site | Notes |
|---|---|---|
| Insert recording | `AppDatabase.insertRecording` | Called at end of calibration |
| Update recording | `AppDatabase.updateRecording` | Sets `endedAt`, `durationMs` on stop |
| Delete recording | `AppDatabase.deleteRecording` | Transactional: deletes samples then the row |
| Batch insert samples | `AppDatabase.insertSensorSamplesBatch` | Flushed every 2 s by the engine (configurable in tests) |
| List recordings | `AppDatabase.getAllRecordings` | Ordered by `startedAt` desc |
| Get recording | `AppDatabase.getRecording` | Single row by id; used by the detail screen |
| Get samples | `AppDatabase.getSamplesForRecording` | Ordered by `timestampUs` asc |
| Watch samples | `AppDatabase.watchSamplesForRecording` | Not currently used from UI |

## Migrations

Current `schemaVersion = 4`. All upgrades are additive `ALTER TABLE ADD COLUMN` statements.

| From → To | Adds |
|---|---|
| 1 → 2 | `gps_bearing`, `grav_x/y/z`, `pressure` |
| 2 → 3 | `quat_w/x/y/z` |
| 3 → 4 | `lateral_accel` |

## Related pages

- [recording](features/recording.md) — producer of sample rows
- [export-import](features/export-import.md) — consumer of both tables
- [acceleration-calculation](concepts/acceleration-calculation.md) — origin of `forwardAccel`, `lateralAccel`, `grav*`, `quat*`
