# Stack

> Flutter (Dart SDK ^3.10.4) targeting Android + iOS. SQLite via Drift, Provider for state, fl_chart for plots.

**Scope:** [pubspec.yaml](pubspec.yaml), [android/](android/), [ios/](ios/), [analysis_options.yaml](analysis_options.yaml)
**Last verified:** 2026-05-02

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
| `sensors_plus` | ^6.1.1 | Accelerometer, gyroscope, user-accelerometer (linear), barometer streams |
| `geolocator` | ^13.0.2 | GPS position stream with Android foreground-service config |
| `drift` | ^2.25.0 | Typed SQLite ORM + code generation |
| `sqlite3_flutter_libs` | ^0.5.28 | Bundled SQLite binary |
| `fl_chart` | ^0.70.2 | Line charts for recording detail & live view |
| `path_provider` | ^2.1.5 | Locate app documents directory for DB file |
| `path` | ^1.9.1 | Path joining |
| `intl` | ^0.20.2 | Date formatting in recordings list |
| `shared_preferences` | ^2.5.3 | Theme mode + dev-mode flag persistence |
| `file_picker` | ^8.3.7 | Save/pick files for export and import |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

## Dev dependencies

| Package | Purpose |
|---|---|
| `flutter_lints` ^6.0.0 | Lint rules |
| `drift_dev` ^2.25.0 | Codegen for Drift tables |
| `build_runner` ^2.4.15 | Runs the codegen |

## Commands

| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate `database.g.dart` after schema edits |
| `flutter run` | Run on a connected device/emulator |
| `flutter test` | Run the widget/unit test suite under [test/](test/) |
| `flutter build apk` / `flutter build ios` | Platform builds |

## Platform setup

- **Android:** location + foreground-service permissions are declared in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml). The GPS service uses a `ForegroundNotificationConfig` with wake lock to keep streaming when the screen is off.
- **iOS:** location usage description strings in [ios/Runner/Info.plist](ios/Runner/Info.plist).

## Related pages

- [architecture](architecture.md) — how these components connect
- [conventions](conventions.md) — how code is organised
