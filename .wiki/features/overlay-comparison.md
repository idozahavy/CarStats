# Overlay Comparison

> Plot two recordings on the same chart to compare runs — before/after modifications, different weather, different drive modes.

**Scope:** [lib/screens/comparison/comparison_screen.dart](lib/screens/comparison/comparison_screen.dart), [lib/screens/recordings/recordings_screen.dart](lib/screens/recordings/recordings_screen.dart) (multi-select entry point)
**Last verified:** 2026-05-05 (phase 09)

---

## Summary

Pick two recordings from the recordings list via a multi-select mode and view their speed-over-time and acceleration-over-time curves on shared time axes, aligned at first movement.

## User-facing behavior

- **Selection:** long-press a recording tile in the list to enter selection mode. Tap any tile to add or remove it from the selection (capped at two — a third tap is ignored). The app bar swaps to a "{n} selected" title with a leading close icon (cancels selection) and a *Compare* action that enables once exactly 2 are selected.
- **Comparison screen:** two header cards show recording name + duration, each tagged with the colour used for that recording on both charts. Two charts follow:
  1. **Speed over time** — both lines, primary + tertiary colour scheme.
  2. **Acceleration over time** — both lines, same colour mapping.
  Each chart has a coloured-dot legend below it.
- **Alignment:** each recording is shifted so its *first movement* (first sample where `gpsSpeed * 3.6 ≥ 1`) sits at x = 0. Samples before first movement are dropped from the chart. If a recording never crosses 1 km/h, a small notice appears above the charts and that line is omitted.

## Data flow

1. Selection state is local to `RecordingsScreen` (`Set<int> _selectedIds`); cleared on close, when the comparison screen is opened, or when an item disappears from the list.
2. Tapping *Compare* pushes `ComparisonScreen(idA, idB)` and clears the selection.
3. `ComparisonScreen` loads both recordings + sample lists in parallel via `Future.wait`, computes `firstMovementUs` for each, then renders the two charts.
4. Each chart maps samples to `FlSpot` after subtracting the per-recording `firstMovementUs`, then runs `downsample` (from [chart_utils.dart](../lib/core/chart_utils.dart)) per line to cap at 500 points.
5. No persistence — comparisons are re-derived on each open.

## Business rules

- Exactly two recordings can be compared at once. A third tap while two are selected is a no-op.
- Long-press is reserved for entering selection mode. Rename + delete moved to a per-tile trailing popup menu (3-dot `Icons.more_vert`).
- Different recording durations render in full — the shared X axis auto-scales to whichever ends later after alignment.
- Both lines use the same colour pair on both charts: A → `colorScheme.primary`, B → `colorScheme.tertiary`.
- Acceleration chart uses fixed bounds `minY: -1.5, maxY: 1.5` (g). Speed chart uses `minY: 0` and a 50 km/h-snapped `maxY` driven by the higher of the two recordings.
- A recording with no movement above 1 km/h shows a notice and contributes no line to either chart.

## Gotchas

- Selection state is *not* persisted across rebuilds outside the screen — leaving the recordings screen clears it. This is intentional.
- The trash icon was removed from the tile in favour of the popup menu — existing tests that tapped `Icons.delete_outline` were updated to drive the popup instead.
- Both sample lists are loaded fully in memory; `downsample` keeps chart rendering bounded but the load itself is not paginated.

## Status

Complete (MVP).

## Related pages

- [recording-history](recording-history.md) — selection-mode entry point lives here
- [benchmarks](benchmarks.md) — overlaying benchmarks across recordings is a future enhancement
- [data-model](../data-model.md) — sample shape used as input
