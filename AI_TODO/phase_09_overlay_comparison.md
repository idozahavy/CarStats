# Phase 09 — Overlay Comparison

## Goal
Let the user pick two recordings and view both curves on the same chart, aligned at first movement. Reachable from the recordings list via a multi-select mode.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/features/overlay-comparison.md` (planned), `.wiki/features/recording-history.md`, `.wiki/data-model.md`.

**Code layout**:
- `lib/screens/recordings/recordings_screen.dart` — list with filter chips, delete, import
- `lib/screens/recording_detail/recording_detail_screen.dart` — single-recording detail
- `lib/core/chart_utils.dart` — `downsample` helper
- `lib/data/database/database.dart` — `RecordingStore.getSamplesForRecording`

**Hard rules**:
- Read a file before modifying it.
- Update wiki per `.wiki/SCHEMA.md`.

## Decisions already made (do not relitigate)

- **Alignment**: at *first movement* (first sample where `gpsSpeed * 3.6 ≥ 1`). Both recordings shifted so their first-movement timestamp = 0.
- **Different durations**: render both fully without truncation; chart auto-scales to the longer one.
- **Entry point**: dedicated comparison screen reachable from the recordings list via a multi-select mode (long-press a tile to enter selection mode, tap to add/remove, an app-bar button "Compare" appears once exactly 2 are selected).
- **Charts**: two charts on the comparison screen — Speed-over-time and Acceleration-over-time. Each shows two lines with distinct colours (use `colorScheme.primary` and `colorScheme.tertiary`) and a legend.
- **No persistence**: re-derived on each open.

## Scope

**In:**
- Multi-select mode in the recordings list (long-press to enter, tap to toggle, exit via back button or "Cancel")
- Comparison screen with two charts and a legend
- Alignment logic
- Tests

**Out:**
- Overlay benchmarks (Phase 08 already computes per-recording benchmarks; comparing them is a future enhancement)
- More than 2 recordings at once
- Deleting from selection mode (preserve the existing single-tile delete via the trash icon)
- Long-press rename collision: if Phase 04 added long-press rename, fold rename into selection-mode UX (e.g., long-press enters selection; rename moves to the trailing menu).

## Tasks (ordered)

### A. Multi-select mode in the list
File: `lib/screens/recordings/recordings_screen.dart`

1. Add to the screen state:
   ```dart
   final Set<int> _selectedIds = {};
   bool get _selectionMode => _selectedIds.isNotEmpty;
   ```
2. Tile behaviour:
   - Long-press: add tile id to `_selectedIds`. Re-render.
   - Tap when in selection mode: toggle membership.
   - Tap when not in selection mode: open detail (existing behavior).
3. App bar in selection mode:
   - Title: "{n} selected"
   - Leading: close icon → clear selection
   - Action: "Compare" button enabled only when `_selectedIds.length == 2`. Pushes the comparison screen with both ids.
4. Tile rendering: when in selection mode, show a leading checkbox or selected/unselected state. Hide the trailing delete icon while selecting.
5. Resolve any conflict with the long-press-rename added in Phase 04: rename moves to a trailing popup menu (3-dot icon) that exists on every tile; long-press is now reserved for selection.

### B. Comparison screen
File: `lib/screens/comparison/comparison_screen.dart` (new)

1. Constructor: `ComparisonScreen({required int idA, required int idB})`.
2. State: load both recordings + sample lists in parallel via `Future.wait`.
3. Layout:
   - App bar title: "Compare"
   - Two cards at top: each shows recording name + duration (so the user knows which colour is which).
   - "Speed over time" chart (`SizedBox(height: 300)`) — two lines.
   - "Acceleration over time" chart — two lines.
   - Legend row below each chart with coloured dots + recording names.
4. Alignment: pre-process each sample list to compute `firstMovementUs` (first sample where `gpsSpeed * 3.6 >= 1`). Subtract that offset when building chart spots. Samples before first movement are dropped.

### C. Charts
1. Reuse `downsample` from `lib/core/chart_utils.dart`. Apply per-line.
2. Use the chart-bounds conventions established in Phase 03: `minY: -1.5, maxY: 1.5` for accel-time; `minY: 0` and a 50 km/h-snapped `maxY` for speed-time.
3. X-axis: time in seconds, max = max(durationA, durationB) after alignment. Title: "Time since first movement (s)".

### D. Tests
1. `test/screens/recordings_screen_test.dart` extension:
   - Long-press a tile enters selection mode (selection count = 1).
   - Tapping another tile selects it; "Compare" becomes enabled.
   - Tapping a third tile while two are selected — define behavior: deselects one of the others (keep most-recent two)? OR ignore? **Pick: ignore the third tap, do nothing.** Test this.
   - Closing selection clears state.
2. `test/screens/comparison_screen_test.dart` (new):
   - Renders both recording names.
   - Charts render without throwing for fixtures with realistic samples.
   - Alignment: a fixture where recording A starts moving at t=2s and B starts moving at t=5s renders both starting at x=0.

### E. Verify
- `flutter analyze` — clean
- `flutter test` — all green
- Manual: pick two recordings on a device, confirm overlay reads correctly.

### F. Wiki updates
- `.wiki/features/overlay-comparison.md` — flip status from "Planned" to current. Replace `_TBD_` markers with concrete decisions.
- `.wiki/features/recording-history.md` — document the multi-select mode entry point.
- `.wiki/architecture.md` — add `ComparisonScreen` to the UI box.
- `.wiki/log.md` — append dated entry.

## Acceptance criteria

- Long-pressing a recording tile enters selection mode
- Selecting exactly 2 enables the "Compare" action
- Comparison screen shows two recordings on shared time axes (Speed and Acceleration), aligned at first movement
- Tests cover selection-mode state transitions and chart-data alignment
- All tests green; analyzer clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/features/overlay-comparison.md` (flip from planned)
- `.wiki/features/recording-history.md`
- `.wiki/architecture.md`
- `.wiki/log.md` (append entry)
