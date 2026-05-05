# Benchmarks

> Derived view over user recordings: standard speed-to-speed times, ¼ mile, max forward acceleration at speed buckets, and sudden-acceleration response from cruise.

**Scope:** [lib/services/benchmarks/benchmarks.dart](lib/services/benchmarks/benchmarks.dart), [lib/services/benchmarks/standard.dart](lib/services/benchmarks/standard.dart), [lib/services/benchmarks/max_accel_at_speed.dart](lib/services/benchmarks/max_accel_at_speed.dart), [lib/services/benchmarks/sudden_accel.dart](lib/services/benchmarks/sudden_accel.dart), [lib/screens/recording_detail/recording_detail_screen.dart](lib/screens/recording_detail/recording_detail_screen.dart)
**Last verified:** 2026-05-05 (phase 08)

---

## Summary

Benchmarks are **not a separate capture** — they are a computed analysis derived from an existing user recording's samples. Results are recomputed on each detail-screen open; nothing is persisted.

## User-facing behavior

The recording detail screen renders a **Benchmarks** section under the three time-series charts with three sub-sections:

1. **Standard** — 4 cards: 0–100 km/h, 0–60 mph, 80–120 km/h, ¼ mile (with trap speed). Each card shows the time or `—` when no qualifying segment exists; hover/long-press reveals the unavailable reason as a tooltip.
2. **Max Accel at Speed** — a list of 8 speed buckets centred at 0, 20, 40, 60, 80, 100, 120, 140 km/h with each bucket's peak forward G.
3. **Sudden Acceleration** — a list of detected events (cruise speed, peak G, response time in ms); empty state when no events.

Dev recordings show a `MaterialBanner` above the three sub-sections: "Dev recording — benchmark results may be unreliable."

## Data flow

Detail screen calls `computeBenchmarks(_samples)` on each build. The single entry point fans out to three pure-function calculators and returns a `BenchmarkReport { standard, maxAccelByBucket, suddenAccelEvents }`. No DB writes; no caching. Sample lists are typically 3000+ samples (50 Hz × duration) but in-memory iteration is fast.

## Business rules

- **Standard speed-to-speed**: walks GPS-tagged samples chronologically. For each candidate start (sample where `gpsSpeed*3.6 ≤ startKmh`), finds the earliest later sample where `gpsSpeed*3.6 ≥ endKmh`. Validates the segment: no GPS gap > 2 s inside it, and no continuous negative `forwardAccel` lasting > 0.5 s (the driver did not lift). Picks the *fastest* qualifying segment.
- **¼ mile**: anchors at the *first* sample where `gpsSpeed*3.6 ≤ 5` km/h. Integrates distance via the trapezoidal rule on `gpsSpeed`. The crossing time at 402.336 m is found by solving the quadratic that arises from linearly interpolating speed inside the bracketing sample interval. Trap speed is the linearly-interpolated `gpsSpeed` at the 402.336 m point. Same lift/gap validation as the speed-to-speed benchmarks.
- **Max accel at speed bucket**: for each bucket centre c ∈ {0, 20, …, 140}, filters samples whose `gpsSpeed*3.6` falls in `[c-10, c+10]`. Peak G = `max(forwardAccel) / 9.81` over those samples. Buckets with no qualifying samples report `peakG: null`.
- **Sudden-acceleration events**: cruise window = ≥3 s of contiguous GPS-tagged samples whose speed range stays within ±2 km/h. After each cruise window, scans up to 2 s for the first sample where forward G > 0.2 g and stays above 0.2 g for ≥ 0.5 s. Reports cruise mean speed (km/h), response time (cruise end → trigger sample), and peak G during the burst. Subsequent cruise windows are searched after the burst clears.
- Results are derived per-recording — no cross-recording aggregation.

## Gotchas

- The 0–100 / 0–60 / 80–120 calculators iterate every candidate start and report the *fastest* segment, so a recording with several attempts surfaces the best one. The ¼ mile uses the *first* near-stop start only — running multiple ¼ miles in one session reports only the first.
- The lift-detection window (`> 0.5 s of continuous negative forwardAccel`) is intentionally lenient: real recordings have brief `forwardAccel` dips around 0 from sensor noise even during a clean pull. A momentary negative blip won't invalidate the segment.
- Peak G in a bucket isn't smoothed — a single noisy sample can dominate. A future iteration may apply a short rolling average before bucketing.
- Sudden-accel response time is measured from the *last* sample of the cruise window to the *first* sample whose forward G crosses the trigger. With 50 Hz data, the minimum representable response time is ~20 ms.
- The sudden-accel detector does not chain: after one event, it advances past the burst's sustain period and starts looking for the next cruise window. It will not double-report inside a single sustained pull.

## Status

Complete (MVP).

## Related pages

- [recording-history](recording-history.md) — entry point on the detail screen
- [data-model](../data-model.md) — source columns
- [acceleration-calculation](../concepts/acceleration-calculation.md) — origin of `forwardAccel`
