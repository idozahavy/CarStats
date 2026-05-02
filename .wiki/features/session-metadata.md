# Session Metadata

> Per-recording car / drive-mode / passenger / fuel / tyre / weather context, stored in normalised tables and round-tripped through JSON export/import.

**Scope:** [lib/data/database/database.dart](lib/data/database/database.dart), [lib/screens/manage_cars/manage_cars_screen.dart](lib/screens/manage_cars/manage_cars_screen.dart), [lib/screens/recording_detail/metadata_sheet.dart](lib/screens/recording_detail/metadata_sheet.dart), [lib/screens/recording_detail/recording_detail_screen.dart](lib/screens/recording_detail/recording_detail_screen.dart), [lib/services/export_service.dart](lib/services/export_service.dart)
**Last verified:** 2026-05-02 (phase 06)

---

## Summary

Recordings can carry an optional metadata row describing the session, plus an optional reference to a reusable car profile. None of it is captured at start time — the user fills it in after stopping, from the recording detail screen.

## User-facing behavior

- **Manage Cars screen** — reachable from `Settings → Vehicles → My Cars`. Lists every `CarProfile`. Tap a row to edit. The FAB opens the same form with empty fields. Swipe a row left to delete (with a confirmation dialog).
- **Metadata on the recording detail screen** — above the summary mini-cards:
  - If no metadata row exists for the recording: an outlined `Add details` button.
  - If metadata exists: a card showing car name, drive mode, passengers, fuel level, tyres, weather (whichever fields are set), with an `Edit details` text button.
- **Edit Details bottom sheet** — `showModalBottomSheet`. Form fields:
  - Car (dropdown of profiles + a `+ Add new car…` text button that pushes Manage Cars and reloads on return)
  - Drive mode (text)
  - Passenger count (numeric)
  - Fuel level % (numeric)
  - Tyre type (text)
  - Weather (text)
  - Free text notes (multi-line)
  - Save / Cancel buttons.

## Data flow

1. User opens a recording → `RecordingDetailScreen._load` calls `getRecording`, `getSamplesForRecording`, `getMetadataForRecording`, and (if `carProfileId != null`) `getCarProfile`.
2. Tapping `Add details` / `Edit details` calls `showMetadataSheet`. The sheet loads `getAllCarProfiles` for its dropdown.
3. Save calls `RecordingStore.upsertMetadata` — inserts on first save, updates the same row thereafter (one row per recording).
4. The detail screen reloads metadata + linked car after the sheet returns `true`.
5. Manage Cars screen calls `getAllCarProfiles` on init; `insertCarProfile` / `updateCarProfile` / `deleteCarProfile` for CRUD. Delete is transactional and nulls `carProfileId` on any referencing metadata rows before deleting the profile.

## Business rules

- All metadata fields are optional. Saving with everything blank still creates the row (unless the user simply doesn't tap Save).
- `CarProfile.name` is required (1–100 chars); other car fields are optional.
- Fuel-type and transmission are populated by dropdowns with fixed option sets (`petrol/diesel/electric/hybrid/''` and `auto/manual/dct/''`) but the underlying column is free-form text — older or imported rows can hold any string.
- Deleting a car profile preserves recordings: their `carProfileId` becomes `NULL` but the metadata row, including `driveMode`, `passengerCount`, etc., is kept.
- Deleting a recording cascades to its metadata row (transactional in `deleteRecording`).
- Metadata is preserved through JSON export/import — see [export-import](export-import.md) for the v2 shape and the v1 backward-compat path.
- CSV export still emits raw samples only; a `# Metadata not included in CSV; export as JSON for full round-trip.` comment line is prepended.

## Gotchas

- The metadata sheet's car dropdown is the only place a profile can be selected per recording. If no profiles exist, the `+ Add new car…` button is the only path that doesn't require leaving the sheet — it pushes Manage Cars and reloads on return.
- Imports never deduplicate car profiles by name. Re-importing the same JSON produces another `CarProfile` row; the user cleans up via Manage Cars.
- Auto-detection of weather, altitude, fuel level, etc. is out of scope and deferred to a later phase.

## Status

Complete (MVP).

## Related pages

- [recording-history](recording-history.md) — invocation point for the metadata sheet
- [export-import](export-import.md) — round-trip format
- [data-model](../data-model.md) — `CarProfiles`, `RecordingMetadata` tables
- [benchmarks](benchmarks.md) — primary downstream consumer (planned)
