# Benchmarks (planned)

> Derived view over user recordings: max acceleration at speed, sudden-acceleration response at speed, and standard benchmarks (0–100 km/h, ¼ mile, etc.).

**Scope:** _TBD._ Not yet implemented. Future consumer of samples stored by [lib/data/database/database.dart](lib/data/database/database.dart).
**Last verified:** 2026-04-21

---

## Summary

Benchmarks are **not a separate capture** — they are a computed analysis derived from an existing user recording's samples.

## User-facing behavior

Planned:

- Entry point lives on a recording's detail view (screen location _TBD_).
- Two on-demand computed views over a single recording:
  1. **Max acceleration at speed** — peak forward acceleration at discrete speed buckets (e.g. 60, 80, 100 km/h).
  2. **Sudden acceleration at speed** — isolates segments where the car cruises at a steady speed and the driver floors it; reports response time and peak g.
- Standard benchmarks computed when enough data exists:
  - 0–100 km/h time
  - 0–60 mph time
  - 80–120 km/h time (in-gear pull)
  - ¼ mile (400 m) time and trap speed

## Data flow

_TBD._ Expected shape: detail screen → benchmarks screen → reads already-loaded `List<SensorSample>` → segment detector → per-benchmark computation → render. No DB writes; results re-derived on open.

## Business rules

- Input is a **user recording** (dev recordings share the same column set and should work identically).
- The view is read-only and re-derived on demand — no denormalised storage.
- A benchmark is only emitted when the recording contains a qualifying segment (e.g. a contiguous 0 → 100 km/h stretch).
- Speed-bucket granularity, segment-detection thresholds, and unit toggle (km/h vs mph) are _TBD_.

## Gotchas

- Open question: whether the view lives in the detail screen or a dedicated comparison screen.
- Open question: tolerance for GPS gaps inside a candidate segment — tunnels can void an otherwise-clean 0–100 run.

## Status

Planned.

## Related pages

- [recording-history](recording-history.md) — entry point will sit here
- [data-model](../data-model.md) — source columns
