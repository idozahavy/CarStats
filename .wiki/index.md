# Wiki Index

> Master catalog of all wiki pages. One-line summaries. Updated on every wiki change.

## Architecture & Infrastructure
- [architecture](architecture.md) — System-level view of AccelStats: Flutter app recording sensors + GPS to derive car acceleration.
- [data-model](data-model.md) — Two-table SQLite schema (Recordings + SensorSamples) managed by Drift.
- [stack](stack.md) — Flutter / Dart ^3.10.4 targeting Android + iOS; Drift, Provider, fl_chart.

## Conventions
- [conventions](conventions.md) — Folder layout, naming, layer responsibilities, state-management rules.

## Features
- [benchmarks](features/benchmarks.md) — *(planned)* Derived view: max / sudden accel at speed, 0–100, ¼ mile.
- [export-import](features/export-import.md) — CSV / JSON export of a recording; JSON import.
- [overlay-comparison](features/overlay-comparison.md) — *(planned)* Plot two recordings on the same chart.
- [recording](features/recording.md) — Captures a driving session with 5 s calibration then continuous sampling.
- [recording-history](features/recording-history.md) — Browse, filter, delete recordings; detail view with summary + charts.
- [session-metadata](features/session-metadata.md) — Per-recording car / drive-mode / passenger / fuel / tyre / weather context, with reusable car profiles.
- [settings](features/settings.md) — Theme mode and dev-mode toggle persisted via SharedPreferences.

## Concepts
- [acceleration-calculation](concepts/acceleration-calculation.md) — Math pipeline: calibration, gyro+accel filter, GPS heading, decomposition.
- [state-management](concepts/state-management.md) — Provider at a single root; three ChangeNotifiers plus the DB interface.
