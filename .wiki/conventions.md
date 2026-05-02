# Conventions

> How this codebase is organised and the rules that keep it consistent.

**Scope:** [lib/](lib/), [test/](test/), [analysis_options.yaml](analysis_options.yaml)
**Last verified:** 2026-05-02

---

## Folder layout

```
lib/
├── main.dart                # App bootstrap, provider wiring, permission gate
├── core/                    # Cross-cutting utilities (constants, theme, providers, chart helpers)
├── data/
│   ├── database/            # Drift tables + generated code
│   └── models/              # Reserved for future domain models
├── screens/<screen>/        # One folder per screen (home, recording, recording_detail, recordings, settings)
├── services/                # Sensor, GPS, recording engine, calibration, export
└── widgets/                 # Reserved for shared widgets (currently empty)
```

## Naming

| Thing | Convention | Example |
|---|---|---|
| Dart files | `snake_case.dart` | `recording_engine.dart` |
| Classes | `PascalCase` | `RecordingEngine`, `CalibrationResult` |
| Constants (grouped) | `static const` on a class named `*Constants` / `*Keys` | `SensorConstants.accelerometerSamplingMs`, `StorageKeys.themeMode` |
| Private members | leading `_` | `_sampleBuffer`, `_onRecordingGps` |
| Test-only setters | annotated `@visibleForTesting` | `flushInterval`, `useCalibrationTimer` |

## Layer responsibilities

| Layer | May depend on | May not depend on |
|---|---|---|
| `screens/*` | `core`, `services`, `data/database` (through `RecordingStore`) | Concrete `AppDatabase` (use the interface) |
| `services/recording_engine.dart` | Other services, `RecordingStore`, `core/constants` | UI/Flutter widgets |
| `services/calibration_service.dart` | `sensor_service.dart` for `AccelerometerReading` | Nothing else |
| `services/sensor_service.dart`, `gps_service.dart` | `sensors_plus` / `geolocator` | Engine, UI |
| `data/database/database.dart` | `drift` | UI, services |

## State management

- `Provider` at app root in [lib/main.dart](lib/main.dart).
- Global state lives in `ChangeNotifier`s:
  - `ThemeProvider`, `SettingsProvider` (persisted via `SharedPreferences`)
  - `RecordingEngine` (recording orchestration)
- `RecordingStore` is provided as a plain `Provider<RecordingStore>.value` — screens read the interface, not the concrete DB class.
- UI rebuilds inside an active recording are throttled to ~10 Hz (sensor streams fire ~50 Hz).

## Database conventions

- One `AppDatabase` instance, guarded by a factory singleton.
- Schema is defined with Drift's declarative tables; run codegen (`build_runner`) after edits.
- Migrations are additive `ALTER TABLE ADD COLUMN` — never drop or rename.
- Always bump `schemaVersion` and append an `if (from < N)` block.

## Sensor + GPS conventions

- Sampling: 20 ms period (≈ 50 Hz) for accelerometer / gyroscope / linear accel; 1 s for barometer; 1 Hz natural rate for GPS (set via `LocationAccuracy.bestForNavigation`).
- All numeric sensor columns are nullable — never assume a sample has every field.
- Speeds below `SensorConstants.gpsStationarySpeed` (0.5 m/s) snap to 0 in the display pipeline.
- Small accelerations below `SensorConstants.accelNoiseFloor` (0.05 g) are clamped to 0 while stationary.

## Error handling

- Sensor and GPS stream errors are swallowed with `onError: (_) {}` — dropouts (tunnels, device quirks) are expected.
- GPS permission is checked once at app start by `_PermissionGate` in [lib/main.dart](lib/main.dart).
- Export/import failures surface as `SnackBar` messages, not thrown to the UI layer.
- Import failures and mid-recording permission loss surface as SnackBar messages; recording always saves what was captured.

## Testing

- Tests live in [test/](test/) and use `flutter_test`.
- Engine tests set `flushInterval = Duration.zero` and `useCalibrationTimer = false` to avoid real timers.
- `flutter test --reporter expanded` shows the same test name on multiple consecutive lines because the cumulative pass counter `+N` ticks each time *any* parallel test file completes; the displayed name is just the most-recently-active test. This is verbose runner output, not a `pumpAndSettle` retry loop. Use `--reporter compact` if it gets in the way.

## Related pages

- [architecture](architecture.md) — the components these rules govern
- [data-model](data-model.md) — database specifics
- [stack](stack.md) — tooling
