# Export & Import

> CSV or JSON export of a single recording; JSON import of a previously exported recording.

**Scope:** [lib/services/export_service.dart](lib/services/export_service.dart), [lib/screens/recording_detail/recording_detail_screen.dart](lib/screens/recording_detail/recording_detail_screen.dart), [lib/screens/recordings/recordings_screen.dart](lib/screens/recordings/recordings_screen.dart)
**Last verified:** 2026-04-21

---

## Summary

Users export a recording (with its samples) from the detail screen and import a previously exported JSON from the recordings list.

## User-facing behavior

- **Export:** detail screen → download icon → choose *Export as CSV* or *Export as JSON*. A save dialog opens; the default filename is `<sanitized name>_<id>.<ext>`. On success, a `SnackBar` shows the save path.
- **Import:** recordings list → upload icon → pick a `.json` file. On success, the new recording appears in the list.

## File format

- **JSON:** `{ "recording": {...}, "samples": [...] }`. Recording fields: `id`, `name`, `startedAt`, `endedAt`, `durationMs`, `notes`. Each sample is a flat object with every `SensorSamples` column (nullable fields may be `null`).
- **CSV:** one header row + one row per sample. Columns mirror the JSON sample shape, minus identity columns. Nulls are empty strings.

## Business rules

- Recording `name` is sanitised with `[^\w\s\-]` → `_` before use in a filename.
- Export format choice routes to `_toCsv` or `_toJson`.
- Import creates a **new** recording row; the original `id` is not preserved.
- Import only supports JSON. CSV is export-only.

## Gotchas

- On desktop platforms (Windows / Linux / macOS), `file_picker` does not write the bytes passed to `saveFile`. `ExportService.exportRecording` compensates with an explicit `File.writeAsString` after the path is chosen.
- Import assumes a trusted JSON shape — malformed fields will throw. Exceptions are caught in the UI and displayed as a `SnackBar`.
- Import does not validate that `samples[*].timestampUs` is monotonic or that any column is physically plausible.

## Status

Complete (MVP).

## Related pages

- [recording-history](recording-history.md) — invocation points
- [data-model](../data-model.md) — column mapping
