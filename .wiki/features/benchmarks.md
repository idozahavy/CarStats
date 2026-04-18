### Benchmarks (planned)

> Derived view over user recordings: max acceleration at speed, sudden-acceleration response at speed, and standard benchmarks (0–100 km/h, ¼ mile, etc.).

**Scope:** Not yet implemented. Future consumer of [lib/data/database/database.dart](lib/data/database/database.dart) sample data.
**Last verified:** 2026-04-18

---

### Summary

Benchmarks are **not a separate capture** — they are a computed analysis derived from an existing user recording's samples.

### Planned behaviour

Two benchmark types over a single recording:

1. **Max acceleration at speed** — peak forward acceleration available at discrete speed buckets (e.g. 60, 80, 100 km/h). Visualises the car's real-world power curve.
2. **Sudden acceleration at speed** — isolates segments where the car cruises at a steady speed and the driver floors it. Reports response time and peak g-force from semi-rest — the real-world overtaking / merging measure.

Standard benchmarks computed when enough data exists:

- 0–100 km/h time
- 0–60 mph time
- 80–120 km/h time (in-gear pull)
- ¼ mile (400 m) time and trap speed

### Business rules (intended)

- Input is a **user recording** (though dev recordings have the same column set and should work identically).
- The view is read-only and re-derived on demand — no denormalised storage.
- A benchmark is only emitted when the recording contains a qualifying segment (e.g. a contiguous 0 → 100 km/h stretch).

### Open questions

- Where does the benchmark UI live? Likely a new screen reachable from a recording's detail view.
- Speed-bucket granularity, segment detection thresholds, and unit toggles (km/h vs mph) are not yet specified.

### Status

Planned.

### Related pages

- [recording-history](recording-history.md) — entry point will sit here
- [data-model](../data-model.md) — source columns
