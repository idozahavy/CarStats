# Data Model

> Four-table SQLite schema managed by Drift: one `Recordings` row per session, many `SensorSamples` rows per recording, optional `RecordingMetadata` row, and reusable `CarProfiles`.

**Scope:** [lib/data/database/database.dart](lib/data/database/database.dart), [lib/data/database/database.g.dart](lib/data/database/database.g.dart)
**Last verified:** 2026-05-02 (phase 06)

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

### `CarProfiles`

| Column | Type | Notes |
|---|---|---|
| `id` | int, PK, autoincrement | |
| `name` | text, 1–100 chars | Display label (e.g. "Daily Driver") |
| `make` | text, default '' | Manufacturer (e.g. "Honda") |
| `model` | text, default '' | Model (e.g. "Civic") |
| `year` | int, nullable | |
| `fuelType` | text, default '' | Free-form but populated from `petrol` / `diesel` / `electric` / `hybrid` / `''` |
| `transmission` | text, default '' | Free-form but populated from `auto` / `manual` / `dct` / `''` |

Reusable across recordings — picked from a dropdown in the metadata sheet.

### `RecordingMetadata`

One optional row per recording. Created lazily when the user opens the metadata sheet on the detail screen.

| Column | Type | Notes |
|---|---|---|
| `id` | int, PK, autoincrement | |
| `recordingId` | int, FK → `Recordings.id` | One row per recording (enforced by `upsertMetadata`) |
| `carProfileId` | int, FK → `CarProfiles.id`, nullable | Cleared to `NULL` when the referenced profile is deleted |
| `driveMode` | text, default '' | e.g. eco / normal / sport — free-form |
| `passengerCount` | int, nullable | |
| `fuelLevelPercent` | int, nullable | 0–100 |
| `tyreType` | text, default '' | |
| `weatherNote` | text, default '' | |
| `freeText` | text, default '' | Multi-line notes |

## Access patterns

| Operation | Site | Notes |
|---|---|---|
| Insert recording | `AppDatabase.insertRecording` | Called at end of calibration |
| Update recording | `AppDatabase.updateRecording` | Sets `endedAt`, `durationMs` on stop |
| Rename recording | `AppDatabase.renameRecording` | Single-column update; called from the long-press rename in `RecordingsScreen` |
| Delete recording | `AppDatabase.deleteRecording` | Transactional: deletes samples then the row |
| Batch insert samples | `AppDatabase.insertSensorSamplesBatch` | Flushed every 2 s by the engine (configurable in tests) |
| List recordings | `AppDatabase.getAllRecordings` | Ordered by `startedAt` desc |
| Get recording | `AppDatabase.getRecording` | Single row by id; used by the detail screen |
| Get samples | `AppDatabase.getSamplesForRecording` | Ordered by `timestampUs` asc |
| Watch samples | `AppDatabase.watchSamplesForRecording` | Not currently used from UI |
| List car profiles | `AppDatabase.getAllCarProfiles` | Ordered by `name` asc |
| Get car profile | `AppDatabase.getCarProfile` | Returns `null` if missing |
| Insert car profile | `AppDatabase.insertCarProfile` | |
| Update car profile | `AppDatabase.updateCarProfile` | |
| Delete car profile | `AppDatabase.deleteCarProfile` | Transactional: nulls `carProfileId` on referencing metadata rows, then deletes the profile |
| Get metadata | `AppDatabase.getMetadataForRecording` | Returns `null` if no row for the recording |
| Upsert metadata | `AppDatabase.upsertMetadata` | One row per recording — updates if present, inserts otherwise |

`deleteRecording` also cascades to `recording_metadata` before sample rows.

## Migrations

Current `schemaVersion = 5`. Pre-v5 upgrades are additive `ALTER TABLE ADD COLUMN`; v5 adds two new tables via `Migrator.createTable`.

| From → To | Adds |
|---|---|
| 1 → 2 | `gps_bearing`, `grav_x/y/z`, `pressure` |
| 2 → 3 | `quat_w/x/y/z` |
| 3 → 4 | `lateral_accel` |
| 4 → 5 | `car_profiles`, `recording_metadata` |

## Related pages

- [recording](features/recording.md) — producer of sample rows
- [export-import](features/export-import.md) — consumer of both tables
- [acceleration-calculation](concepts/acceleration-calculation.md) — origin of `forwardAccel`, `lateralAccel`, `grav*`, `quat*`
