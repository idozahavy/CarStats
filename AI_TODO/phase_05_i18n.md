# Phase 05 — Internationalization (English + Hebrew, RTL)

## Goal
Externalise every user-facing string into ARB files and ship the app in two locales: English (default) and Hebrew (RTL). Add a Settings → Language picker that overrides device locale.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/architecture.md`, `.wiki/features/settings.md`, `.wiki/conventions.md`, `.wiki/stack.md`.

**Code layout**:
- All user-facing strings currently sit hardcoded inside `lib/screens/**/*.dart` and `lib/main.dart` (permission gate text, snackbars, dialog titles, button labels, axis labels in charts, etc.)
- `lib/core/providers.dart` — `ThemeProvider`, `SettingsProvider` (will get a sibling `LocaleProvider`)
- `lib/core/constants.dart` — `StorageKeys` (will gain a key)

**Hard rules**:
- Read a file before modifying it.
- Update wiki per `.wiki/SCHEMA.md`.
- Hebrew translations: machine-translate now using your best knowledge — the user will review later. Use natural Hebrew, not transliteration. For technical units (km/h, g, m/s), keep them in Latin script with their numeric values; only translate labels.

## Decisions already made (do not relitigate)

- **Locale switching**: Settings → Language picker with three options: System, English, Hebrew. Stored under a new `StorageKeys.locale` preference.
- **Translation source for Hebrew**: machine-translate now (user reviews later). Do not use placeholders like `[HE] <english>`.
- **RTL**: Flutter handles RTL automatically once `MaterialApp.locale` is `he`. Verify charts and rows render correctly under RTL — fix only if visually broken.
- **Units**: do not translate "km/h", "g", "m/s", "°", "hPa". Translate the descriptive labels around them ("Speed", "Acceleration", "Pitch", etc.).

## Scope

**In:**
- `flutter_localizations` setup
- ARB files for `en` and `he`
- `LocaleProvider` (ChangeNotifier) wired into `MaterialApp.locale`
- Settings → Language picker
- All user-facing strings in `lib/` migrated to `AppLocalizations`
- Tests for the locale provider and one screen rendered in Hebrew
- RTL visual sanity check (handled automatically by Flutter)

**Out:**
- Translation of wiki pages (English-only documentation stays)
- Language picker for the system permission dialog (system-controlled)
- Translation of error messages from third-party packages (geolocator, file_picker)
- Schema changes

## Tasks (ordered)

### A. Add localization tooling
1. Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_localizations:
       sdk: flutter
     intl: ^0.20.2  # already present — keep it
   ```
2. Add to `pubspec.yaml` under `flutter:`:
   ```yaml
   generate: true
   ```
3. Create `l10n.yaml` at project root:
   ```yaml
   arb-dir: lib/l10n
   template-arb-file: app_en.arb
   output-localization-file: app_localizations.dart
   ```

### B. Create ARB files
1. Create `lib/l10n/app_en.arb` and `lib/l10n/app_he.arb`.
2. Inventory every user-facing string by reading each file under `lib/main.dart`, `lib/screens/`, and any user-visible strings in `lib/services/`. Extract them all to keys.
3. Naming convention: `screenContext_purpose` — e.g., `home_title`, `home_subtitle`, `home_startButton`, `home_viewRecordingsButton`, `permission_required_title`, `permission_required_message`, `permission_grant_button`, `recording_calibrating_title`, `recording_calibrating_hint`, `recording_speed_label`, `recording_accel_label`, `recording_pitch_label`, `recording_roll_label`, `recording_peak_accel_label`, `recording_peak_brake_label`, `recording_peak_lateral_label`, `recording_heading_locked`, `recording_heading_calibrating`, `recording_stop_button`, `recording_saved_title`, `recording_view_button`, `recording_back_home_button`, `recordings_title`, `recordings_empty_title`, `recordings_empty_hint`, `recordings_filter_all`, `recordings_filter_user`, `recordings_filter_dev`, `recordings_delete_title`, `recordings_delete_message`, `recordings_delete_confirm`, `recordings_delete_cancel`, `recordings_import_success`, `recordings_import_failed`, `detail_export_csv`, `detail_export_json`, `detail_max_speed`, `detail_max_accel`, `detail_max_brake`, `detail_duration`, `detail_chart_speed_vs_accel`, `detail_chart_accel_time`, `detail_chart_speed_time`, `detail_export_saved_to`, `detail_export_failed`, `settings_title`, `settings_appearance_section`, `settings_developer_section`, `settings_theme_label`, `settings_theme_system`, `settings_theme_light`, `settings_theme_dark`, `settings_devmode_label`, `settings_devmode_hint`, `settings_language_label`, `settings_language_system`, `settings_language_english`, `settings_language_hebrew`, ...
4. For each key, write the English value in `app_en.arb` and the Hebrew translation in `app_he.arb`. Include `@@locale` metadata at the top of each file.
5. Use ICU placeholders for interpolated strings (e.g. `detail_export_saved_to`: `"Saved to {path}"`).

### C. Wire MaterialApp
File: `lib/main.dart`

1. Import `package:flutter_localizations/flutter_localizations.dart` and the generated `package:accel_stats/l10n/app_localizations.dart`.
2. On `MaterialApp`, add:
   ```dart
   localizationsDelegates: AppLocalizations.localizationsDelegates,
   supportedLocales: AppLocalizations.supportedLocales,
   locale: localeProvider.locale, // null = device default
   ```
3. Wrap `MaterialApp` with `Consumer<LocaleProvider>` (alongside the existing `ThemeProvider` consumer).

### D. LocaleProvider
File: `lib/core/providers.dart`

1. Add a new class:
   ```dart
   class LocaleProvider extends ChangeNotifier {
     Locale? _locale; // null = follow system
     final SharedPreferences _prefs;
     LocaleProvider(this._prefs) {
       final stored = _prefs.getString(StorageKeys.locale);
       if (stored != null) _locale = Locale(stored);
     }
     Locale? get locale => _locale;
     Future<void> setLocale(Locale? value) async {
       _locale = value;
       if (value == null) {
         await _prefs.remove(StorageKeys.locale);
       } else {
         await _prefs.setString(StorageKeys.locale, value.languageCode);
       }
       notifyListeners();
     }
   }
   ```
2. In `lib/core/constants.dart`, add `static const String locale = 'locale';` to `StorageKeys`.
3. Register in `MultiProvider` in `lib/main.dart`.

### E. Settings → Language picker
File: `lib/screens/settings/settings_screen.dart`

1. Add a new section after Appearance, before Developer: `Language`.
2. Use the same picker pattern as `_showThemePicker`. Three options: System (null), English (`Locale('en')`), Hebrew (`Locale('he')`).
3. Show the current selection's localised name in the subtitle.

### F. String migration
1. Walk every `.dart` file under `lib/` and replace each user-facing string literal with `AppLocalizations.of(context)!.<key>` (or assign once to `final l = AppLocalizations.of(context)!;` at the top of the build method).
2. For strings inside non-widget code (e.g., the SnackBar messages built inside async handlers), pass `BuildContext` through or capture the localised string before the `await`.
3. Do NOT translate:
   - Constants that are not user-facing (sensor key names, JSON field names)
   - Drift schema column names
   - Log messages
   - The auto-generated default recording name `Run <timestamp>` — leave the format intact, but localise the word "Run" via `home_default_recording_name_prefix`.

### G. Tests
1. `test/core/locale_provider_test.dart` (new):
   - `setLocale(Locale('he'))` persists `'he'` to prefs and notifies listeners.
   - `setLocale(null)` removes the pref.
   - Constructor reads pref correctly.
2. `test/screens/settings_screen_test.dart` extension:
   - Renders the Language section.
   - Tapping Hebrew calls `LocaleProvider.setLocale(Locale('he'))`.
3. `test/screens/home_screen_he_test.dart` (new):
   - Pump the home screen with `LocaleProvider` set to Hebrew.
   - Assert the Hebrew title text appears (`find.text(<expected hebrew>)`).
4. Update existing screen tests if hardcoded English strings were the assertion target — switch to keys via `AppLocalizations.of(context)!.<key>`. The simplest pattern: keep English assertions and pump in default `en` locale.

### H. Verify
- `flutter pub get` then `flutter gen-l10n` (or just run `flutter analyze` which triggers codegen)
- `flutter analyze` — clean
- `flutter test` — all green
- Manual on device: switch to Hebrew, confirm RTL layout looks correct.

### I. Wiki updates
- `.wiki/features/settings.md` — document the new Language section and `LocaleProvider`.
- `.wiki/stack.md` — add `flutter_localizations` to Dependencies.
- `.wiki/architecture.md` — note `LocaleProvider` in the Layers table under State.
- `.wiki/conventions.md` — under "State management", add `LocaleProvider` to the list of root providers. Add a new short subsection "Localization": all user-facing strings live in `lib/l10n/app_<locale>.arb`.
- `.wiki/log.md` — append dated entry.

## Acceptance criteria

- App runs in English (default) and Hebrew (with RTL layout)
- Settings → Language picker switches locale and persists
- Zero hardcoded user-facing English strings remain in `lib/screens/` or `lib/main.dart` (greppable check)
- `lib/l10n/app_en.arb` and `lib/l10n/app_he.arb` cover every key
- All existing tests pass under default locale; new tests pass
- `flutter analyze` clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/features/settings.md`
- `.wiki/stack.md`
- `.wiki/architecture.md`
- `.wiki/conventions.md`
- `.wiki/log.md` (append entry)
