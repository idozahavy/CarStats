# Export & Import

> CSV or JSON export of a single recording; JSON import of a previously exported recording.

**Scope:** [lib/services/export_service.dart](lib/services/export_service.dart), [lib/screens/recording_detail/recording_detail_screen.dart](lib/screens/recording_detail/recording_detail_screen.dart), [lib/screens/recordings/recordings_screen.dart](lib/screens/recordings/recordings_screen.dart)
**Last verified:** 2026-05-02 (phase 06)

---

## Summary

Users export a recording (with its samples) from the detail screen — either as a saved file via a save dialog, or via the system share sheet — and import a previously exported JSON from the recordings list.

## User-facing behavior

- **Save:** detail screen → download icon → choose *Save as CSV* or *Save as JSON*. A save dialog opens; the default filename is `<sanitized name>_<id>.<ext>`. On success, a `SnackBar` shows the save path.
- **Share:** detail screen → download icon → choose *Share as CSV* or *Share as JSON*. The file is written to the OS temp directory and the system share sheet is invoked (`SharePlus.instance.share`). The recording name is used as the share `subject`.
- **Import:** recordings list → upload icon → pick a `.json` file. On success, the new recording appears in the list.

## File format

- **JSON:** `{ "exportVersion": 2, "recording": {...}, "carProfile": {...}|null, "metadata": {...}|null, "samples": [...] }`. `exportVersion` is the first key and is required. Recording fields: `id`, `name`, `startedAt`, `endedAt`, `durationMs`, `notes`. `carProfile`: `name`, `make`, `model`, `year`, `fuelType`, `transmission`. `metadata`: `driveMode`, `passengerCount`, `fuelLevelPercent`, `tyreType`, `weatherNote`, `freeText`. Either block may be `null` if the source recording has no profile / no metadata. Each sample is a flat object with every `SensorSamples` column (nullable fields may be `null`).
- **CSV:** opens with a single comment line `# Metadata not included in CSV; export as JSON for full round-trip.` followed by one header row + one row per sample. Columns mirror the JSON sample shape, minus identity columns. Nulls are empty strings. CSV has no version field and is export-only.

## Business rules

- Recording `name` is sanitised with `[^\w\s\-]` → `_` before use in any filename (save and share share the same sanitiser).
- Export format choice routes to `_toCsv` or `_toJson`.
- The detail screen models the export menu with a private `_ExportAction` enum (`saveCsv` / `saveJson` / `shareCsv` / `shareJson`); the dispatch site maps it to `ExportFormat` + the save/share branch.
- `ExportService.shareRecording` writes to `getTemporaryDirectory()` and does not return the file — share success/failure is owned by the platform sheet.
- Import creates a **new** recording row; the original `id` is not preserved.
- Import only supports JSON. CSV is export-only.
- Import validates `exportVersion`: must be an integer in `1..ExportService.exportVersion` (currently `2`). Anything else (missing, wrong type, out of range) throws `FormatException` and is surfaced to the user as a `SnackBar`.
- Import validates shape: missing or wrongly-typed `recording` / `samples` keys throw `FormatException` with a clear message.
- v1 imports succeed and yield a recording with no metadata and no car profile (the v2 blocks are simply ignored when absent). v2 imports insert a new `CarProfiles` row (no name dedupe) and a `RecordingMetadata` row keyed to the new recording id.
- `ExportService.importRecordingFromJson(db, jsonString)` is the testable entry point; `ExportService.importRecording(db)` is the picker-driven wrapper.
- `ExportService.exportRecording` and `ExportService.shareRecording` accept optional `metadata` and `carProfile` parameters; the recording detail screen passes the values it loaded from the DB.

## Gotchas

- On desktop platforms (Windows / Linux / macOS), `file_picker` does not write the bytes passed to `saveFile`. `ExportService.exportRecording` compensates with an explicit `File.writeAsString` after the path is chosen.
- Import does not validate that `samples[*].timestampUs` is monotonic or that any column is physically plausible — only the shape and version are enforced.
- Bumping `exportVersion` is breaking for *forward* compatibility (older app versions cannot read newer files); the importer accepts the full `1..currentVersion` range so newer apps still load older exports.

## Status

Complete (MVP).

## Related pages

- [recording-history](recording-history.md) — invocation points
- [data-model](../data-model.md) — column mapping
