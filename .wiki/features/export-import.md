# Export & Import

> CSV or JSON export of a single recording; JSON import of a previously exported recording.

**Scope:** [lib/services/export_service.dart](lib/services/export_service.dart), [lib/screens/recording_detail/recording_detail_screen.dart](lib/screens/recording_detail/recording_detail_screen.dart), [lib/screens/recordings/recordings_screen.dart](lib/screens/recordings/recordings_screen.dart)
**Last verified:** 2026-05-02

---

## Summary

Users export a recording (with its samples) from the detail screen and import a previously exported JSON from the recordings list.

## User-facing behavior

- **Export:** detail screen → download icon → choose *Export as CSV* or *Export as JSON*. A save dialog opens; the default filename is `<sanitized name>_<id>.<ext>`. On success, a `SnackBar` shows the save path.
- **Import:** recordings list → upload icon → pick a `.json` file. On success, the new recording appears in the list.

## File format

- **JSON:** `{ "exportVersion": 1, "recording": {...}, "samples": [...] }`. `exportVersion` is the first key and is required. Recording fields: `id`, `name`, `startedAt`, `endedAt`, `durationMs`, `notes`. Each sample is a flat object with every `SensorSamples` column (nullable fields may be `null`).
- **CSV:** one header row + one row per sample. Columns mirror the JSON sample shape, minus identity columns. Nulls are empty strings. CSV has no version field.

## Business rules

- Recording `name` is sanitised with `[^\w\s\-]` → `_` before use in a filename.
- Export format choice routes to `_toCsv` or `_toJson`.
- Import creates a **new** recording row; the original `id` is not preserved.
- Import only supports JSON. CSV is export-only.
- Import validates `exportVersion`: missing or `!= ExportService.exportVersion` (currently `1`) throws `FormatException` and is surfaced to the user as a `SnackBar`.
- Import validates shape: missing or wrongly-typed `recording` / `samples` keys throw `FormatException` with a clear message.
- `ExportService.importRecordingFromJson(db, jsonString)` is the testable entry point; `ExportService.importRecording(db)` is the picker-driven wrapper.

## Gotchas

- On desktop platforms (Windows / Linux / macOS), `file_picker` does not write the bytes passed to `saveFile`. `ExportService.exportRecording` compensates with an explicit `File.writeAsString` after the path is chosen.
- Import does not validate that `samples[*].timestampUs` is monotonic or that any column is physically plausible — only the shape and version are enforced.
- Bumping `exportVersion` is a breaking change for older exports; do it only when the JSON shape changes incompatibly.

## Status

Complete (MVP).

## Related pages

- [recording-history](recording-history.md) — invocation points
- [data-model](../data-model.md) — column mapping
