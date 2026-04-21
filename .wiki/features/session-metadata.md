# Session Metadata (planned)

> Capture car, tyre, weather, load, and drive-mode context per recording so benchmarks can be interpreted correctly.

**Scope:** _TBD._ Not yet implemented. The `Recordings.notes` text column exists as a placeholder.
**Last verified:** 2026-04-21

---

## Summary

Every recording should travel with enough context to explain why it performed the way it did. None of the fields below are captured today.

## User-facing behavior

Planned:

- A metadata panel on the recording detail screen (or a pre-recording step) prompts for vehicle, state, environment, and context fields.
- A reusable car profile (make / model / year) is stored once and referenced by new recordings — the user picks from existing profiles or creates a new one.
- Filtering and benchmark comparisons can use metadata to group comparable runs.

Planned fields:

| Group | Fields |
|---|---|
| Vehicle | make, model, year, fuel type (petrol / diesel / electric / hybrid), transmission (auto / manual / DCT) |
| State | fuel level / battery %, tyre type / brand / size, passenger count / load estimate, drive mode (eco / normal / sport), windows open, AC on/off, gear (if manual) |
| Environment | air temperature, weather, road surface, altitude (barometer + GPS) |
| Context | date, time, location name, device model + OS version |

## Data flow

_TBD._ Two storage options under consideration:

1. Normalised tables — `car_profiles` with FK from `Recordings`, plus a `recording_metadata` table for per-run fields.
2. A JSON blob in the existing `Recordings.notes` column (no schema change).

The decision rides on whether any field needs to be indexed/queried independently (option 1) or whether bulk read-back inside the app is sufficient (option 2).

## Business rules

- Which fields are mandatory vs optional: _TBD_.
- Whether any values can be auto-detected (altitude from barometer + GPS, temperature from a weather API): _TBD_.
- Metadata must be preserved across export / import (both CSV and JSON paths need to round-trip it).

## Gotchas

- **Why it matters:** benchmarks (e.g. 0–100 km/h time) are only comparable between runs with similar load, fuel, and drive mode. Altitude + temperature affect naturally-aspirated engine power measurably. Tyre brand/size affects grip.
- Auto-detected values (weather API) require the user to be online at recording time — offline fallback behaviour is _TBD_.

## Status

Planned.

## Related pages

- [recording](recording.md) — capture point
- [benchmarks](benchmarks.md) — primary consumer
- [data-model](../data-model.md) — where these fields will land
