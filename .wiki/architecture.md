### Architecture

> System-level view of AccelStats: a native Flutter app that records phone sensors + GPS to derive a car's forward acceleration.

**Scope:** [lib/main.dart](lib/main.dart), [lib/services/](lib/services/), [lib/data/](lib/data/), [lib/screens/](lib/screens/), [lib/core/](lib/core/)
**Last verified:** 2026-04-18

---

### Components

```
┌─────────────────────────────────────────────┐
│                  UI (Screens)               │
│  home · recording · recording_detail ·      │
│  recordings · settings                      │
└──────────────────────┬──────────────────────┘
                       │ Provider (ChangeNotifier)
┌──────────────────────┴──────────────────────┐
│              RecordingEngine                │
│   (orchestrates sensors + GPS + DB writes)  │
└───┬────────────┬────────────┬──────────┬────┘
    │            │            │          │
┌───┴────┐  ┌────┴────┐  ┌────┴─────┐ ┌──┴──────┐
│Sensor  │  │GpsService│ │Calibration│ │ AppDb   │
│Service │  │          │ │ + Decom-  │ │ (Drift) │
│accel,  │  │position, │ │ poser     │ │sqlite   │
│gyro,   │  │speed,    │ │           │ │         │
│linAcc, │  │heading   │ │           │ │         │
│baro    │  │          │ │           │ │         │
└────────┘  └──────────┘ └───────────┘ └─────────┘
```

### Layers

| Layer | Purpose | Key files |
|---|---|---|
| UI | Material 3 screens, Provider-driven rebuilds | [lib/screens/](lib/screens/) |
| State | ChangeNotifier providers wired at root | [lib/core/providers.dart](lib/core/providers.dart), [lib/main.dart](lib/main.dart) |
| Engine | Recording orchestration, calibration, sample assembly | [lib/services/recording_engine.dart](lib/services/recording_engine.dart) |
| Math | Gravity calibration, acceleration decomposition, heading auto-calibration | [lib/services/calibration_service.dart](lib/services/calibration_service.dart) |
| Sensors | Sensor stream adapters (accelerometer, gyroscope, linear accel, barometer) | [lib/services/sensor_service.dart](lib/services/sensor_service.dart) |
| GPS | Position stream with foreground notification on Android | [lib/services/gps_service.dart](lib/services/gps_service.dart) |
| Persistence | Drift database (SQLite) with migrations | [lib/data/database/database.dart](lib/data/database/database.dart) |
| I/O | CSV/JSON export, JSON import via file picker | [lib/services/export_service.dart](lib/services/export_service.dart) |

### Deployment

- Single Flutter codebase targeting Android + iOS.
- No backend — all data lives on-device in an SQLite file under the app documents directory (`accel_stats.sqlite`).
- Android uses a `ForegroundNotificationConfig` so GPS keeps streaming when the screen is off during recording.
- Location permission is gated at startup by `_PermissionGate` in [lib/main.dart:79](lib/main.dart#L79).

### Data flow — recording session

1. User taps *Start Recording* → `HomeScreen._startRecording` asks `RecordingEngine.startRecording`.
2. Engine transitions to `calibrating`, starts `SensorService` + `GpsService`, and collects accelerometer samples for 5 s.
3. On countdown end, `CalibrationService.compute()` averages samples → `CalibrationResult` (gravity vector + rotation matrix).
4. Engine creates a `Recordings` row, transitions to `recording`, and subscribes to all streams.
5. For each accel sample: complementary-filter gravity correction → `AccelerationDecomposer.decompose` → forward / lateral / vertical.
6. Samples are buffered and batch-inserted every 2 s; UI rebuilds are throttled to ~10 Hz.
7. On stop: flush buffer, update `endedAt` + `durationMs` on the recording row.

### Related pages

- [recording](features/recording.md) — feature page for the recording flow
- [acceleration-calculation](concepts/acceleration-calculation.md) — the math pipeline
- [data-model](data-model.md) — database schema
