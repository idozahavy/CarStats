# Settings

> Theme mode (light / dark / system) and dev-mode toggle. Persisted via `SharedPreferences`.

**Scope:** [lib/screens/settings/settings_screen.dart](lib/screens/settings/settings_screen.dart), [lib/core/providers.dart](lib/core/providers.dart), [lib/core/theme.dart](lib/core/theme.dart), [lib/core/constants.dart](lib/core/constants.dart)
**Last verified:** 2026-04-21

---

## Summary

A single screen exposing two persisted preferences.

## User-facing behavior

- **Theme mode:** radio-style picker → writes `ThemeMode.name` to `SharedPreferences` under key `theme_mode`. `MaterialApp.themeMode` reads from `ThemeProvider`.
- **Dev mode:** switch → writes bool to `SharedPreferences` under key `dev_mode`. The live flag is only read at recording creation: `HomeScreen._startRecording` passes it to `RecordingEngine.startRecording` as `isDev`, which stamps the `Recordings.isDevRecording` column. The "Dev" filter chip in `RecordingsScreen` reads that persisted column, not the live setting.

## Business rules

- Preferences are loaded synchronously from `SharedPreferences` in each provider's constructor; defaults: `ThemeMode.system`, `devMode = false`.
- Changing a preference writes to storage and calls `notifyListeners()`.

## Gotchas

- `SharedPreferences` is initialised once in `main()` and passed into both providers. No fallback if initialisation fails (it won't on supported platforms).

## Status

Complete (MVP).

## Related pages

- [recording](recording.md) — reads `devMode` at session start to stamp `isDevRecording`
- [recording-history](recording-history.md) — filters by the stamped `isDevRecording` column
