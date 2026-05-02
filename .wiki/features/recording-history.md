# Recording History

> Browse, filter, and inspect past recordings. Detail view renders summary cards and three charts (speed-vs-accel, accel-vs-time, speed-vs-time).

**Scope:** [lib/screens/recordings/recordings_screen.dart](lib/screens/recordings/recordings_screen.dart), [lib/screens/recording_detail/recording_detail_screen.dart](lib/screens/recording_detail/recording_detail_screen.dart), [lib/core/chart_utils.dart](lib/core/chart_utils.dart)
**Last verified:** 2026-05-02 (phase 03)

---

## Summary

Two screens: a list of recordings (with All/User/Dev filter chips) and a detail screen per recording.

## User-facing behavior

- **List:** ordered newest-first. Each tile shows name, started-at, formatted duration, and a dev/user icon. Tap → detail; trailing bin icon → delete (with confirm dialog). Toolbar has an *Import* action (see [export-import](export-import.md)).
- **Filter chips:** All / User / Dev. Filtering is in-memory on the loaded list — no separate DB query.
- **Detail:** four summary mini-cards (duration, max speed, max accel, max brake). Three charts:
  1. Speed (km/h) vs Forward Accel (g)
  2. Forward Accel (g) vs Time (s)
  3. Speed (km/h) vs Time (s)
- Toolbar has an *Export* menu (CSV or JSON).

## Data flow

1. `RecordingsScreen` calls `RecordingStore.getAllRecordings()` on init, orders by `startedAt desc`.
2. `_filter` (local enum) determines which slice of the loaded list is rendered.
3. Tap → `RecordingDetailScreen` loads `getRecording(id)` + `getSamplesForRecording(id)`.
4. Detail screen computes summary stats inline (max speed, max / min forward accel).
5. Each chart converts samples to `FlSpot`s and calls `downsample` (from [chart_utils.dart](lib/core/chart_utils.dart)) to cap at 500 points for rendering.

## Business rules

- `isDevRecording` is set at creation from the live *Dev mode* toggle. It never changes after.
- Delete is transactional: sample rows are removed before the recording row.
- When returning from the detail screen, the list reloads (`_load()`) — so a delete from detail would be reflected, but currently delete only lives on the list.

## Gotchas

- The entire sample set is loaded into memory when opening a detail page. Long recordings (> many minutes at 50 Hz) can be tens of thousands of rows — `downsample` protects chart rendering but the list itself is not paginated.
- Summary stats in detail (max/min forward accel) are computed from `forwardAccel` in m/s² divided by 9.81 — they ignore clamped/noise-floor behaviour applied during live display.
- The list uses `_filteredRecordings` in the empty-state check, so "No recordings yet" shows whenever the filter hides everything — not only when the DB is empty.

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
