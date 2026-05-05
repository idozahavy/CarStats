# Stack

> Flutter (Dart SDK ^3.10.4) targeting Android + iOS. SQLite via Drift, Provider for state, fl_chart for plots.

**Scope:** [pubspec.yaml](pubspec.yaml), [android/](android/), [ios/](ios/), [analysis_options.yaml](analysis_options.yaml), [.github/workflows/](.github/workflows/), [assets/icon/](assets/icon/)
**Last verified:** 2026-05-05 (phase 10)

---

## Runtime

| Tech | Version | Purpose |
|---|---|---|
| Dart SDK | ^3.10.4 | Language runtime |
| Flutter | (from SDK) | UI framework |

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | ChangeNotifier-based state management |
| `flutter_localizations` | (from SDK) | Material/Cupertino/Widgets localization delegates for `AppLocalizations` |
| `sensors_plus` | ^6.1.1 | Accelerometer, gyroscope, user-accelerometer (linear), barometer streams |
| `geolocator` | ^13.0.2 | GPS position stream with Android foreground-service config |
| `drift` | ^2.25.0 | Typed SQLite ORM + code generation |
| `sqlite3_flutter_libs` | ^0.5.28 | Bundled SQLite binary |
| `fl_chart` | ^0.70.2 | Line charts for recording detail & live view |
| `path_provider` | ^2.1.5 | Locate app documents directory for DB file |
| `path` | ^1.9.1 | Path joining |
| `intl` | ^0.20.2 | Date formatting in recordings list |
| `shared_preferences` | ^2.5.3 | Theme mode, locale, and dev-mode flag persistence |
| `file_picker` | ^8.3.7 | Save/pick files for export and import |
| `share_plus` | ^11.0.0 | System share sheet for exporting recordings via OS apps |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

## Dev dependencies

| Package | Purpose |
|---|---|
| `flutter_lints` ^6.0.0 | Lint rules |
| `drift_dev` ^2.25.0 | Codegen for Drift tables |
| `build_runner` ^2.4.15 | Runs the codegen |
| `flutter_launcher_icons` ^0.14.1 | Generates Android + iOS launcher icons from `assets/icon/icon.png` |

## Commands

| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate `database.g.dart` after schema edits |
| `flutter gen-l10n` | Regenerate `lib/l10n/app_localizations*.dart` after editing ARB files (also runs implicitly on `pub get`) |
| `flutter run` | Run on a connected device/emulator |
| `flutter test` | Run the widget/unit test suite under [test/](test/) |
| `flutter build apk` / `flutter build ios` | Platform builds |
| `dart run flutter_launcher_icons` | Regenerate platform launcher icons after editing `assets/icon/icon.png` |

## CI

- [.github/workflows/ci.yml](.github/workflows/ci.yml) — runs on `pull_request` and `push` to `main`. Steps: `actions/checkout@v4` → `subosito/flutter-action@v2` (channel `stable`, cache enabled) → `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → `flutter test`.
- Quality gate: a PR cannot be merged unless analyze + test both pass.

## Release signing (Android)

- Repository ships without a keystore. `flutter run` and debug builds work as-is; release builds default to debug-key signing until the operator opts in.
- Template: [android/key.properties.template](android/key.properties.template). The real `key.properties` and any `*.jks` are gitignored via [android/.gitignore](android/.gitignore).
- The signing block in [android/app/build.gradle.kts](android/app/build.gradle.kts) is commented out by default; uncomment after creating `key.properties` per the README's *Release signing (Android)* section.

## Platform setup

- **Android:** location + foreground-service permissions are declared in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml). The GPS service uses a `ForegroundNotificationConfig` with wake lock to keep streaming when the screen is off.
- **iOS:** location usage description strings in [ios/Runner/Info.plist](ios/Runner/Info.plist).

## Related pages

- [architecture](architecture.md) — how these components connect
- [conventions](conventions.md) — how code is organised
