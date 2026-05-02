# Settings

> Theme mode, language, and dev-mode toggle. Persisted via `SharedPreferences`.

**Scope:** [lib/screens/settings/settings_screen.dart](lib/screens/settings/settings_screen.dart), [lib/core/providers.dart](lib/core/providers.dart), [lib/core/theme.dart](lib/core/theme.dart), [lib/core/constants.dart](lib/core/constants.dart), [lib/l10n/](lib/l10n/)
**Last verified:** 2026-05-02

---

## Summary

A single screen exposing two persisted preferences.

## User-facing behavior

- **Theme mode:** radio-style picker → writes `ThemeMode.name` to `SharedPreferences` under key `theme_mode`. `MaterialApp.themeMode` reads from `ThemeProvider`.
- **Language:** radio-style picker with three options (Follow device language, English, Hebrew) → writes the language code to `SharedPreferences` under key `locale`, or removes it for "follow device". `MaterialApp.locale` reads from `LocaleProvider`. Hebrew flips `Directionality` to RTL automatically.
- **Dev mode:** switch → writes bool to `SharedPreferences` under key `dev_mode`. The live flag is only read at recording creation: `HomeScreen._startRecording` passes it to `RecordingEngine.startRecording` as `isDev`, which stamps the `Recordings.isDevRecording` column. The "Dev" filter chip in `RecordingsScreen` reads that persisted column, not the live setting.

## Business rules

- Preferences are loaded synchronously from `SharedPreferences` in each provider's constructor; defaults: `ThemeMode.system`, `locale = null` (follow device), `devMode = false`.
- Changing a preference writes to storage and calls `notifyListeners()`.
- All user-facing strings live in [lib/l10n/app_en.arb](lib/l10n/app_en.arb) (template) and [lib/l10n/app_he.arb](lib/l10n/app_he.arb). The `flutter` tool generates `AppLocalizations` from these on `pub get` / `gen-l10n`.

## Gotchas

- `SharedPreferences` is initialised once in `main()` and passed into both providers. No fallback if initialisation fails (it won't on supported platforms).

## Status

Complete (MVP).

## Related pages

- [recording](recording.md) — reads `devMode` at session start to stamp `isDevRecording`
- [recording-history](recording-history.md) — filters by the stamped `isDevRecording` column
