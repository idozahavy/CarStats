# Phase 04 — UX Polish

## Goal
Add the four small UX gaps that make the app feel finished: name-on-start dialog, rename-from-list, share-sheet on export, and an empty-state CTA on the recordings list.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/features/recording.md`, `.wiki/features/recording-history.md`, `.wiki/features/export-import.md`.

**Code layout**:
- `lib/screens/home/home_screen.dart` — entry, currently auto-names `Run <timestamp>`
- `lib/screens/recordings/recordings_screen.dart` — list with filter chips, delete, import
- `lib/screens/recording_detail/recording_detail_screen.dart` — detail + export menu
- `lib/services/recording_engine.dart::startRecording` — accepts `name`, `isDev`
- `lib/services/export_service.dart` — `exportRecording` returns `File?`
- `lib/data/database/database.dart` — `RecordingStore` interface (no `renameRecording` yet — will be added)

**Hard rules**:
- Read a file before modifying it.
- After schema edits run `dart run build_runner build --delete-conflicting-outputs` (no schema edits this phase, but the `RecordingStore` interface will gain a method).
- Update wiki per `.wiki/SCHEMA.md`.

## Decisions already made (do not relitigate)

- **Name picker**: dialog *before* calibration starts, with `Run <timestamp>` pre-filled and editable. Cancelling the dialog cancels start.
- **Rename**: long-press a tile in the recordings list opens a rename dialog.
- **Share-sheet**: add `share_plus` package alongside the existing save-to-disk export. Detail screen export menu becomes "Save as CSV / Save as JSON / Share as CSV / Share as JSON".
- **Empty-state CTA**: when no recordings exist, show an icon + text + a `FilledButton` that navigates to the home screen's start flow (i.e., `Navigator.popUntil` to root and trigger start, OR pop and rely on user). Implement as a "Start a recording" button that pops back to home.

## Scope

**In:**
- Name picker dialog before calibration
- Long-press rename in recordings list
- Share-sheet via `share_plus`
- Empty-state CTA on recordings list
- `share_plus` added to pubspec
- `RecordingStore.renameRecording(int id, String newName)` method (and Drift impl)
- Tests for each of the above

**Out:**
- i18n (handled by Phase 05 — keep strings hardcoded English here, Phase 05 will externalise)
- Schema changes
- Anything in planned-features wiki pages

## Tasks (ordered)

### A. Add `share_plus`
1. Add to `pubspec.yaml` dependencies (use the latest 11.x available; check pub.dev if unsure — when in doubt, use a version range that resolves with the existing flutter SDK constraint `^3.10.4`):
   ```yaml
   share_plus: ^11.0.0
   ```
2. Run `flutter pub get`.

### B. Name picker dialog
File: `lib/screens/home/home_screen.dart`

1. Replace `_startRecording` with a flow that:
   - Computes default name `Run <yyyy-MM-dd HH:mm>` (use `intl` `DateFormat`).
   - Shows an `AlertDialog` with a `TextField` (autofocus, pre-filled with default), `Cancel` and `Start` buttons. Validate: trimmed name length 1–200 (matches schema constraint).
   - On Cancel: return without calling `engine.startRecording`.
   - On Start: call `engine.startRecording(name: trimmed, isDev: settings.devMode)`, then push the recording screen.
2. Extract the dialog into a small private widget `_NameDialog` to keep the build method readable.

### C. Rename in recordings list
Files: `lib/data/database/database.dart`, `lib/screens/recordings/recordings_screen.dart`

1. Add to the `RecordingStore` interface:
   ```dart
   Future<void> renameRecording(int id, String newName);
   ```
2. Implement on `AppDatabase`:
   ```dart
   @override
   Future<void> renameRecording(int id, String newName) {
     return (update(recordings)..where((t) => t.id.equals(id)))
         .write(RecordingsCompanion(name: Value(newName)));
   }
   ```
3. Update `test/helpers/fakes.dart` so the fake `RecordingStore` implements the new method.
4. In `_RecordingTile`, add `onLongPress` to the `ListTile`. The handler shows a rename dialog identical in shape to the name picker (reuse a shared `_NameDialog` if convenient — duplicating is also fine here).
5. After rename succeeds, call `_load()` to refresh the list.

### D. Share-sheet
File: `lib/services/export_service.dart`, `lib/screens/recording_detail/recording_detail_screen.dart`

1. Add a static method to `ExportService`:
   ```dart
   static Future<void> shareRecording(
     Recording recording,
     List<SensorSample> samples,
     ExportFormat format,
   );
   ```
   Implementation: build the same content as `exportRecording`, write to the system temp directory using `path_provider.getTemporaryDirectory()`, then call `Share.shareXFiles([XFile(file.path)], subject: recording.name)` from `share_plus`.
2. Update the `PopupMenuButton` in the detail screen to expose 4 items: Save CSV, Save JSON, Share CSV, Share JSON. Use a typed enum for the choice (`enum _ExportAction { saveCsv, saveJson, shareCsv, shareJson }`) — drop `ExportFormat` only at the dispatch site.
3. Wrap share calls in try/catch, surfacing errors via SnackBar (matches existing convention).

### E. Empty-state CTA
File: `lib/screens/recordings/recordings_screen.dart`

1. Replace the current empty-state `Text("No recordings yet")` with:
   - `Icon(Icons.directions_car_outlined, size: 64)`
   - `Text("No recordings yet")` (titleMedium)
   - `Text("Tap the button below to record your first run.")` (bodyMedium, secondary color)
   - A `FilledButton.icon` "Start a recording" that calls `Navigator.of(context).pop()` (returns to home where the start button lives).
2. Apply the same empty-state for the *filtered-empty* case (e.g., filter = Dev but no dev recordings exist) — but with text "No recordings match this filter."

### F. Tests
1. `test/screens/home_screen_test.dart`:
   - Add: tapping Start Recording opens the dialog. Dismissing it does NOT call `engine.startRecording`.
   - Add: confirming the dialog with a custom name calls `engine.startRecording` with that name.
2. `test/screens/recordings_screen_test.dart`:
   - Add: long-pressing a tile opens the rename dialog. Confirming calls `RecordingStore.renameRecording`.
   - Add: empty-state shows the CTA button.
3. Update existing tests that currently call `engine.startRecording` directly via the home screen's start button — those tests must now go through the dialog. Use `tester.enterText` and tap `Start`.

### G. Verify
- `flutter analyze` — clean
- `flutter test` — all green
- Manual: confirm rename, share, and empty-state work on a device.

### H. Wiki updates
- `.wiki/features/recording.md` — document the name picker dialog before calibration starts.
- `.wiki/features/recording-history.md` — document long-press rename and the empty-state CTA.
- `.wiki/features/export-import.md` — document share vs save options.
- `.wiki/data-model.md` — add `renameRecording` to the Access patterns table.
- `.wiki/stack.md` — add `share_plus` to the Dependencies table.
- `.wiki/log.md` — append dated entry.

## Acceptance criteria

- Tapping Start Recording on home opens a name dialog; cancelling does not start a recording
- Long-pressing a tile in the recordings list shows a rename dialog
- Detail screen export menu has 4 items (Save/Share × CSV/JSON); Share uses the system share-sheet
- Recordings list shows an actionable empty-state with a CTA
- `share_plus` listed in pubspec; `flutter pub get` succeeds
- `RecordingStore.renameRecording` exists on interface, AppDatabase, and the test fake
- All tests green; analyzer clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/features/recording.md`
- `.wiki/features/recording-history.md`
- `.wiki/features/export-import.md`
- `.wiki/data-model.md`
- `.wiki/stack.md`
- `.wiki/log.md` (append entry)
