# Overlay Comparison (planned)

> Plot two recordings on the same chart to compare runs — before/after modifications, different weather, different drive modes.

**Scope:** _TBD._ Not yet implemented.
**Last verified:** 2026-04-21

---

## Summary

Select two recordings and render their speed-vs-acceleration (or time-aligned) curves on the same chart.

## User-facing behavior

Planned:

- User picks two recordings from the list.
- Choose x-axis: speed (km/h) or elapsed time (s).
- Both curves rendered with distinct colours; visual diff highlights where one run outperforms the other.
- **Sudden-acceleration overlay** — align both runs at a common starting speed and compare the response curves.

## Data flow

_TBD._ Expected shape: list screen → selection mode → comparison screen → loads `getSamplesForRecording(idA)` and `getSamplesForRecording(idB)` in parallel → alignment step → `fl_chart` with two line series.

## Business rules

- Both inputs must be user-mode recordings (or at least share the same column set).
- Alignment strategy for the time axis — start at t=0, at first movement, or at a chosen speed — is _TBD_.
- No persistence: a comparison is re-derived on each open.

## Gotchas

- Open question: whether the overlay lives in a recording's detail screen or in a dedicated comparison screen reachable from the list.
- Open question: behaviour when the two recordings have very different durations or speed ranges (truncate, pad, or decline to overlay).

## Status

Planned.

## Related pages

- [recording-history](recording-history.md)
- [benchmarks](benchmarks.md)
