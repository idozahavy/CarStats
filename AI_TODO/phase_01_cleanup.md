# Phase 01 — Cleanup & Dependencies

## Goal
Remove dead code and unused packages so the project carries no weight into the feature phases. Ship with green tests and clean analyzer.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/stack.md`, `.wiki/conventions.md`.

**Code layout**:
- `lib/main.dart` — bootstrap, providers, permission gate
- `lib/core/` — constants, theme, providers, chart utils
- `lib/data/database/` — Drift schema (`database.dart` + generated `database.g.dart`)
- `lib/screens/<screen>/` — one folder per screen
- `lib/services/` — sensor, GPS, recording engine, calibration, export
- `test/` — flutter_test, with `helpers/fakes.dart` and `helpers/pump_app.dart`

**Hard rules**:
- Read a file before modifying it.
- After schema edits run `dart run build_runner build --delete-conflicting-outputs` (no schema edits expected this phase).
- Update affected wiki pages per `.wiki/SCHEMA.md`.

## Scope

**In:**
- Remove unused packages from `pubspec.yaml`
- Delete `linearAccelMagnitude` field and computation (never rendered)
- Dispose `_db` on app shutdown
- Wiki updates

**Out:**
- Any new features
- Refactoring of working code
- UX changes
- Schema changes

## Pre-flight verifications (do these FIRST, stop if any fails)

Run these greps. If any unexpected match exists, surface it to the user before deleting:

1. `linearAccelMagnitude` — grep `lib/` and `test/`. The wiki log dated 2026-04-21 records it is computed but never rendered. Expected matches: only inside `lib/services/recording_engine.dart` (the field + assignment) and `test/` mocks/fakes. No screen references.
2. `uuid` package — grep `lib/` and `test/` for `package:uuid` and `Uuid(`. Expected: zero matches.
3. `permission_handler` package — grep `lib/` and `test/` for `package:permission_handler`. Expected: zero matches. (`geolocator` already handles location permission via `_PermissionGate` in `lib/main.dart`.)

## Tasks (ordered)

1. **Run pre-flight verifications above.** If any match contradicts the expectation, stop and report to user.
2. **Remove `linearAccelMagnitude`** in `lib/services/recording_engine.dart`:
   - Delete the field from class `RecordingSnapshot`.
   - Remove the `linearAccelMagnitude:` argument from the `RecordingSnapshot` construction inside `_assembleSample`.
   - The underlying `_lastLinearAccel` value and the `_linearAccelSub` subscription must remain — DB columns `linearAccelX/Y/Z` are still written. Only the *derived magnitude on the snapshot* is removed.
3. **Remove unused packages** from `pubspec.yaml`:
   - Delete the `uuid: ^4.5.1` line
   - Delete the `permission_handler: ^11.4.0` line
   - Run `flutter pub get`
4. **Dispose the database on app shutdown** in `lib/main.dart`:
   - In `_AccelStatsAppState.dispose()`, add `_db.close();` before `super.dispose();`
5. **Update tests if needed**:
   - If any test references `linearAccelMagnitude` or asserts on it, update it. Otherwise leave tests untouched.
6. **Verify**:
   - `flutter analyze` — must report "No issues found"
   - `flutter test` — all green
7. **Wiki updates**:
   - `.wiki/stack.md` — remove the `uuid` and `permission_handler` rows from the Dependencies table. Bump `Last verified` to today's date.
   - `.wiki/log.md` — append a new dated entry under the existing entries:
     ```
     ## [<today>] cleanup | Phase 01 — dead code & unused deps removed
     - Removed `linearAccelMagnitude` from RecordingSnapshot (computed but never rendered).
     - Removed unused dependencies `uuid`, `permission_handler` from pubspec.yaml.
     - `_AccelStatsAppState.dispose()` now closes the AppDatabase.
     ```

## Acceptance criteria

- `flutter analyze` → "No issues found"
- `flutter test` → all pass
- `pubspec.yaml` no longer lists `uuid` or `permission_handler`
- `RecordingSnapshot` has no `linearAccelMagnitude` field
- `_AccelStatsAppState.dispose()` calls `_db.close()` before `super.dispose()`
- `.wiki/stack.md` Dependencies table no longer lists removed packages
- `.wiki/log.md` has a new dated entry for this phase

## Wiki updates required

- `.wiki/stack.md` (edit Dependencies, bump Last verified)
- `.wiki/log.md` (append entry)
