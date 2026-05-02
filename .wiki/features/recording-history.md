# Recording History

> Browse, filter, and inspect past recordings. Detail view renders summary cards and three charts (speed-vs-accel, accel-vs-time, speed-vs-time).

**Scope:** [lib/screens/recordings/recordings_screen.dart](lib/screens/recordings/recordings_screen.dart), [lib/screens/recording_detail/recording_detail_screen.dart](lib/screens/recording_detail/recording_detail_screen.dart), [lib/screens/recording_detail/metadata_sheet.dart](lib/screens/recording_detail/metadata_sheet.dart), [lib/core/chart_utils.dart](lib/core/chart_utils.dart), [lib/widgets/name_dialog.dart](lib/widgets/name_dialog.dart)
**Last verified:** 2026-05-02 (phase 06)

---

## Summary

Two screens: a list of recordings (with All/User/Dev filter chips) and a detail screen per recording.

## User-facing behavior

- **List:** ordered newest-first. Each tile shows name, started-at, formatted duration, and a dev/user icon. Tap → detail; long-press → rename dialog (`showNameDialog`); trailing bin icon → delete (with confirm dialog). Toolbar has an *Import* action (see [export-import](export-import.md)).
- **Filter chips:** All / User / Dev. Filtering is in-memory on the loaded list — no separate DB query.
- **Empty state:** when `_recordings` is empty, shows a `directions_car_outlined` icon, "No recordings yet" + a "Start a recording" `FilledButton` that pops back to home. When the filter hides everything but the DB is non-empty, shows "No recordings match this filter." (no CTA).
- **Detail:** an optional metadata card / `Add details` button at the top (see [session-metadata](session-metadata.md)), four summary mini-cards (duration, max speed, max accel, max brake), and three charts:
  1. Speed (km/h) vs Forward Accel (g)
  2. Forward Accel (g) vs Time (s)
  3. Speed (km/h) vs Time (s)
- Toolbar has an *Export* menu with four items: Save as CSV, Save as JSON, Share as CSV, Share as JSON.

## Data flow

1. `RecordingsScreen` calls `RecordingStore.getAllRecordings()` on init, orders by `startedAt desc`.
2. `_filter` (local enum) determines which slice of the loaded list is rendered.
3. Tap → `RecordingDetailScreen` loads `getRecording(id)`, `getSamplesForRecording(id)`, `getMetadataForRecording(id)`, and `getCarProfile(metadata.carProfileId)` if a profile is linked.
4. Detail screen computes summary stats inline (max speed, max / min forward accel).
5. Each chart converts samples to `FlSpot`s and calls `downsample` (from [chart_utils.dart](lib/core/chart_utils.dart)) to cap at 500 points for rendering.
6. The metadata card / button delegates to `showMetadataSheet` ([metadata_sheet.dart](lib/screens/recording_detail/metadata_sheet.dart)), which calls `upsertMetadata` on save and triggers a metadata reload.

## Business rules

- `isDevRecording` is set at creation from the live *Dev mode* toggle. It never changes after.
- Delete is transactional: sample rows are removed before the recording row.
- When returning from the detail screen, the list reloads (`_load()`) — so a delete from detail would be reflected, but currently delete only lives on the list.

## Gotchas

- The entire sample set is loaded into memory when opening a detail page. Long recordings (> many minutes at 50 Hz) can be tens of thousands of rows — `downsample` protects chart rendering but the list itself is not paginated.
- Summary stats in detail (max/min forward accel) are computed from `forwardAccel` in m/s² divided by 9.81 — they ignore clamped/noise-floor behaviour applied during live display.
- Empty-state branching keys off `_recordings` (the unfiltered list): truly-empty DB shows the CTA, filtered-empty shows "No recordings match this filter." with no CTA.

## Chart bounds

- Detail charts render raw samples without curve smoothing (`isCurved: false`); the underlying data is 50 Hz and noisy, so smoothing creates phantom oscillations between samples.
- `Forward Accel vs Time`: fixed `minY: -1.5, maxY: 1.5` g — most car g-forces sit within ±1 g, capping prevents a single noise spike from rescaling the whole chart.
- `Speed vs Time`: `minY: 0`, `maxY = ((maxObservedSpeed / 50).ceil() * 50).clamp(50, 400)` — snaps to round 50 km/h increments.
- `Speed vs Accel`: bounds are unconstrained; the data drives the shape.

## Status

Complete (MVP).

## Related pages

- [recording](recording.md) — produces the items listed here
- [export-import](export-import.md) — how data leaves / enters the list
- [data-model](../data-model.md) — underlying schema
