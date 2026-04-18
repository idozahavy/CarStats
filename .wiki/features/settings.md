### Settings

> Theme mode (light / dark / system) and dev-mode toggle. Persisted via `SharedPreferences`.

**Scope:** [lib/screens/settings/settings_screen.dart](lib/screens/settings/settings_screen.dart), [lib/core/providers.dart](lib/core/providers.dart), [lib/core/theme.dart](lib/core/theme.dart), [lib/core/constants.dart](lib/core/constants.dart)
**Last verified:** 2026-04-18

---

### Summary

A single screen exposing two persisted preferences.

### User-facing behavior

- **Theme mode:** radio-style picker → writes `ThemeMode.name` to `SharedPreferences` under key `theme_mode`. `MaterialApp.themeMode` reads from `ThemeProvider`.
- **Dev mode:** switch → writes bool to `SharedPreferences` under key `dev_mode`. Consumed by:
  - `HomeScreen._startRecording` to set `isDev` on the recording row.
  - `RecordingScreen` (via `SettingsProvider`) to show platform linear-acceleration magnitude next to the custom forward-accel value.
  - `RecordingsScreen` for the Dev filter chip.

### Business rules

- Preferences are loaded synchronously from `SharedPreferences` in each provider's constructor; defaults: `ThemeMode.system`, `devMode = false`.
- Changing a preference writes to storage and calls `notifyListeners()`.

### Gotchas

- `SharedPreferences` is initialised once in `main()` and passed into both providers. No fallback if initialisation fails (it won't on supported platforms).

### Status

Complete (MVP).

### Related pages

- [recording](recording.md) — consumer of dev-mode
- [recording-history](recording-history.md) — consumer of dev-mode (filter)
