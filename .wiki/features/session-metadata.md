### Session Metadata (planned)

> Capture car, tyre, weather, load, and drive-mode context per recording so benchmarks can be interpreted correctly.

**Scope:** Not yet implemented. The `Recordings.notes` text column exists as a placeholder.
**Last verified:** 2026-04-18

---

### Summary

Every recording should travel with enough context to explain why it performed the way it did. None of the fields below are captured today.

### Planned fields

| Group | Fields |
|---|---|
| Vehicle | make, model, year, fuel type (petrol / diesel / electric / hybrid), transmission (auto / manual / DCT) |
| State | fuel level / battery %, tyre type / brand / size, passenger count / load estimate, drive mode (eco / normal / sport), windows open, AC on/off, gear (if manual) |
| Environment | air temperature, weather, road surface, altitude (barometer + GPS) |
| Context | date, time, location name, device model + OS version |

### Car profile

A reusable car profile (make / model / year) should be stored once and referenced by new recordings. Intended as a separate table with a `recordingId` → `carProfileId` FK, or embedded as JSON in `Recordings.notes`. Not yet decided.

### Why it matters

- Benchmarks (e.g. 0–100 km/h time) are only comparable between runs with similar load, fuel, and drive mode.
- Altitude + temperature affect naturally-aspirated engine power measurably.
- Tyre brand/size affects grip and therefore peak lateral / longitudinal g.

### Open questions

- Normalised tables vs a single JSON blob in `notes`.
- Which fields are mandatory vs optional.
- Whether any values can be auto-detected (e.g. altitude from barometer + GPS, temperature from a weather API).

### Status

Planned.

### Related pages

- [recording](recording.md) — capture point
- [benchmarks](benchmarks.md) — consumer
- [data-model](../data-model.md) — where these fields will land
