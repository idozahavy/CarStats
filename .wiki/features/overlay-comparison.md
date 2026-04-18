### Overlay Comparison (planned)

> Plot two recordings on the same chart to compare runs — before/after modifications, different weather, different drive modes.

**Scope:** Not yet implemented.
**Last verified:** 2026-04-18

---

### Summary

Select two recordings and render their speed-vs-acceleration (or time-aligned) curves on the same chart.

### Planned behaviour

- User picks two recordings from the list.
- Choose x-axis: speed (km/h) or elapsed time (s).
- Both curves rendered with distinct colours; visual diff highlights where one run outperforms the other.
- **Sudden acceleration overlay** — align both runs at a common starting speed and compare the response curves.

### Use cases

- Before/after a modification (tyres, intake, tune).
- Different weather / temperature.
- Different drive modes (eco / normal / sport).

### Open questions

- Alignment strategy for the time axis — start at t=0? At first movement? At a chosen speed?
- Whether the overlay lives in the detail screen or a dedicated comparison screen.

### Status

Planned.

### Related pages

- [recording-history](recording-history.md)
- [benchmarks](benchmarks.md)
