# State Management

> Provider-based state at a single root. Three `ChangeNotifier`s plus the database handle cover the whole app.

**Scope:** [lib/main.dart](lib/main.dart), [lib/core/providers.dart](lib/core/providers.dart), [lib/services/recording_engine.dart](lib/services/recording_engine.dart), [lib/data/database/database.dart](lib/data/database/database.dart)
**Last verified:** 2026-04-21

---

## Summary

`MultiProvider` in `AccelStatsApp` wires four providers globally: `RecordingStore` (the DB), `ThemeProvider`, `SettingsProvider`, `RecordingEngine`.

## How it works

| Provider | Shape | Responsibility |
|---|---|---|
| `Provider<RecordingStore>.value` | Interface over `AppDatabase` | Screens call it for CRUD; keeps tests swappable |
| `ChangeNotifierProvider<ThemeProvider>` | `ChangeNotifier` | Persists + emits theme mode |
| `ChangeNotifierProvider<SettingsProvider>` | `ChangeNotifier` | Persists + emits dev-mode flag |
| `ChangeNotifierProvider<RecordingEngine>` | `ChangeNotifier` | Orchestrates the recording session; rebuilds the recording screen |

## Rules

- All providers are constructed in `_AccelStatsAppState.build` / `initState`. Nothing lazy-instantiated later.
- UI uses `context.read<T>()` for one-off actions and `Consumer<T>` / `context.watch<T>()` for rebuilds.
- `RecordingEngine` notifications during a live session are throttled to ~10 Hz so the UI doesn't try to repaint at 50 Hz.
- `RecordingStore` is provided as the interface, not `AppDatabase`, so screens never import the concrete DB class (except where they need row models like `Recording` / `SensorSample`, which are exported from the same file).

## Why

- One root keeps lifecycle simple — services share lifetime with the app, not with any screen.
- Using an interface for the DB keeps the persistence layer swappable for tests and avoids UI code reaching into Drift internals.

## Related pages

- [architecture](../architecture.md)
- [conventions](../conventions.md)
