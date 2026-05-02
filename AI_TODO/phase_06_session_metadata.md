# Phase 06 — Session Metadata + Car Profiles

## Goal
Add reusable car profiles and per-recording session metadata (drive mode, passengers, fuel level, tyre type, weather note, free-text). Round-trip both through export/import. Schema bump to v5.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/data-model.md`, `.wiki/features/recording.md`, `.wiki/features/recording-history.md`, `.wiki/features/session-metadata.md` (planned), `.wiki/features/export-import.md`.

**Code layout**:
- `lib/data/database/database.dart` — Drift schema (`Recordings`, `SensorSamples`, `RecordingStore` interface)
- `lib/data/database/database.g.dart` — generated; rebuild via `dart run build_runner build --delete-conflicting-outputs`
- `lib/screens/recording_detail/recording_detail_screen.dart` — where the metadata form lives
- `lib/services/export_service.dart` — JSON export/import; must include new fields
- `test/helpers/fakes.dart` — fake `RecordingStore` for tests

**Hard rules**:
- Read a file before modifying it.
- Migrations are additive only — `ALTER TABLE ADD COLUMN`. Bump `schemaVersion` from 4 to 5 and append `if (from < 5)` block.
- After schema edits run `dart run build_runner build --delete-conflicting-outputs`.
- The fake `RecordingStore` in `test/helpers/fakes.dart` must implement every interface method.
- Update wiki per `.wiki/SCHEMA.md`.

## Decisions already made (do not relitigate)

- **Storage**: normalised tables — new `CarProfiles` table + new `RecordingMetadata` table with FK to `Recordings` and (nullable) FK to `CarProfiles`. Reusable car profiles, queryable for filtering.
- **MVP fields**:
  - `CarProfiles`: `id`, `name` (display name), `make`, `model`, `year` (int, nullable), `fuelType` (text enum: petrol/diesel/electric/hybrid), `transmission` (text enum: auto/manual/dct).
  - `RecordingMetadata`: `id`, `recordingId` (FK), `carProfileId` (FK, nullable), `driveMode` (text), `passengerCount` (int, nullable), `fuelLevelPercent` (int, nullable), `tyreType` (text), `weatherNote` (text), `freeText` (text). All nullable / default empty — none mandatory.
- **When to fill**: form on the *detail screen* after stop. Not blocking start. A "Add details" CTA on the detail screen if no metadata row exists; otherwise an "Edit details" entry.
- **Auto-detect (weather, altitude)**: out of scope. Defer to a future phase.

## Scope

**In:**
- Schema v5: `CarProfiles` and `RecordingMetadata` tables, additive migration
- `RecordingStore` interface methods for CRUD on both
- "Manage Cars" screen reachable from Settings (list, add, edit, delete car profiles)
- "Edit Details" sheet on the recording detail screen (car profile picker + metadata fields)
- Display: detail screen shows the metadata summary if present
- Export/import round-trip: include `carProfile` and `metadata` blocks at the JSON root, bump `exportVersion` to `2`. Backward-compat: import with `exportVersion: 1` still works (treat metadata as empty).
- Tests: schema migration, CRUD, round-trip, UI rendering

**Out:**
- Filtering/grouping recordings by metadata (recordings list filter chips remain unchanged)
- Auto-detect from APIs
- i18n for new strings (assume Phase 05 already shipped — add new keys to both ARB files; if Phase 05 has not shipped, hardcode English and add a note in the log entry)

## Tasks (ordered)

### A. Schema additions
File: `lib/data/database/database.dart`

1. Add new tables:
   ```dart
   class CarProfiles extends Table {
     IntColumn get id => integer().autoIncrement()();
     TextColumn get name => text().withLength(min: 1, max: 100)();
     TextColumn get make => text().withDefault(const Constant(''))();
     TextColumn get model => text().withDefault(const Constant(''))();
     IntColumn get year => integer().nullable()();
     TextColumn get fuelType => text().withDefault(const Constant(''))();
     TextColumn get transmission => text().withDefault(const Constant(''))();
   }

   class RecordingMetadata extends Table {
     IntColumn get id => integer().autoIncrement()();
     IntColumn get recordingId => integer().references(Recordings, #id)();
     IntColumn get carProfileId => integer().nullable().references(CarProfiles, #id)();
     TextColumn get driveMode => text().withDefault(const Constant(''))();
     IntColumn get passengerCount => integer().nullable()();
     IntColumn get fuelLevelPercent => integer().nullable()();
     TextColumn get tyreType => text().withDefault(const Constant(''))();
     TextColumn get weatherNote => text().withDefault(const Constant(''))();
     TextColumn get freeText => text().withDefault(const Constant(''))();
   }
   ```
2. Add both to `@DriftDatabase(tables: [...])`.
3. Bump `schemaVersion` to `5`. Add a new migration block:
   ```dart
   if (from < 5) {
     await m.createTable(carProfiles);
     await m.createTable(recordingMetadata);
   }
   ```
   (Use `m.createTable` from the migrator parameter — it is type-safe; raw `customStatement` is only needed for column adds on existing tables.)

### B. Codegen
1. Run `dart run build_runner build --delete-conflicting-outputs`.
2. Verify `lib/data/database/database.g.dart` now contains the generated `CarProfile`, `CarProfilesCompanion`, `RecordingMetadataData`, `RecordingMetadataCompanion` classes.

### C. Interface + implementation
File: `lib/data/database/database.dart`

1. Extend `RecordingStore`:
   ```dart
   Future<List<CarProfile>> getAllCarProfiles();
   Future<int> insertCarProfile(CarProfilesCompanion entry);
   Future<void> updateCarProfile(CarProfilesCompanion entry);
   Future<void> deleteCarProfile(int id);
   Future<RecordingMetadataData?> getMetadataForRecording(int recordingId);
   Future<int> upsertMetadata(RecordingMetadataCompanion entry);
   ```
2. Implement on `AppDatabase` using Drift queries. `upsertMetadata`: if a row exists for `recordingId`, update it; otherwise insert.

### D. Update test fakes
File: `test/helpers/fakes.dart`

1. Add in-memory storage maps for car profiles and metadata. Implement every new interface method.

### E. Manage Cars screen
File: `lib/screens/manage_cars/manage_cars_screen.dart` (new)

1. List all car profiles. Tap row → edit. FAB → add. Swipe-to-delete with confirmation.
2. Add an entry in `lib/screens/settings/settings_screen.dart` under a new "Vehicles" section:
   - `ListTile(leading: Icon(Icons.directions_car), title: Text("My Cars"), onTap: → push ManageCarsScreen)`

### F. Edit Details sheet
File: `lib/screens/recording_detail/recording_detail_screen.dart`

1. After loading the recording, also load metadata via `getMetadataForRecording`.
2. Above the summary cards, render either:
   - A "metadata summary" card if metadata exists (car name + drive mode + passengers — three lines), with an "Edit" button.
   - An outlined "Add details" button if no metadata exists.
3. Both routes open a `showModalBottomSheet` containing a form: Car (dropdown of profiles, with "+ Add new..." opening Manage Cars), Drive mode (text field), Passenger count (number), Fuel level % (number), Tyre type (text), Weather (text), Free text (multiline). Save button calls `upsertMetadata`.

### G. Export/import round-trip
File: `lib/services/export_service.dart`

1. Bump `static const int exportVersion = 2;`.
2. In `_toJson`, include after the `samples` array:
   ```dart
   'metadata': metadata == null ? null : { ... },
   'carProfile': carProfile == null ? null : { ... },
   ```
   Update the `exportRecording` signature to accept the optional metadata + car profile (callers in detail screen must fetch and pass them).
3. CSV format: keep unchanged. CSV is for sample analysis only — emit a comment line `# Metadata not included in CSV; export as JSON for full round-trip.` at the top.
4. In `importRecording`:
   - Accept both `exportVersion: 1` (no metadata block) and `exportVersion: 2` (with metadata).
   - For v2: if `carProfile` exists, insert as a new `CarProfiles` row (do not dedupe by name — user can clean up). If `metadata` exists, insert with the new `recordingId` and the new `carProfileId` (if a car was inserted).

### H. Tests
1. `test/data/migration_v4_to_v5_test.dart` (new):
   - Use Drift's migration test helpers (`SchemaVerifier` if available; otherwise spin up a v4 in-memory DB, write a row, simulate upgrade, verify both new tables exist and v4 data is intact).
2. `test/services/export_import_v2_test.dart` (new):
   - Round-trip a recording with metadata + car profile; assert all fields land back.
   - Round-trip a v1 export (no metadata); assert it imports successfully with empty metadata.
3. `test/screens/recording_detail_screen_test.dart` extension:
   - With no metadata → "Add details" button visible.
   - With metadata → summary card visible.
4. `test/screens/manage_cars_screen_test.dart` (new):
   - Empty state → FAB → add → row appears.

### I. Verify
- `flutter analyze` — clean
- `flutter test` — all green (including migration test)
- Manual: install over a v4 build (or simulate via the migration test) and confirm no data loss.

### J. Wiki updates
- `.wiki/data-model.md` — add `CarProfiles` and `RecordingMetadata` tables; bump `schemaVersion` table to v5; add migration entry `4 → 5: car_profiles, recording_metadata`.
- `.wiki/features/session-metadata.md` — flip status from "Planned" to current. Replace the `_TBD_` markers with actual implementation details. Bump `Last verified`.
- `.wiki/features/export-import.md` — document `exportVersion: 2`, the `metadata` and `carProfile` blocks, and the v1 backward-compat path.
- `.wiki/features/recording-history.md` — note that the detail screen now hosts the metadata form.
- `.wiki/architecture.md` — add ManageCarsScreen and MetadataSheet to the UI box.
- `.wiki/log.md` — append dated entry.

## Acceptance criteria

- Schema upgraded to v5 with two new tables; migration test passes
- Car profiles can be created, edited, deleted from a Manage Cars screen reachable from Settings
- Recording detail screen shows a metadata summary or an "Add details" CTA
- Metadata sheet saves to `recording_metadata` table; reload shows the saved values
- JSON export with `exportVersion: 2` round-trips metadata and car profile
- v1 exports still import successfully (treated as empty metadata)
- All tests green; analyzer clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/data-model.md`
- `.wiki/features/session-metadata.md` (flip from planned)
- `.wiki/features/export-import.md`
- `.wiki/features/recording-history.md`
- `.wiki/architecture.md`
- `.wiki/log.md` (append entry)
