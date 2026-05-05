# AccelStats

A Flutter app that records phone sensors (accelerometer, gyroscope, linear-accel, barometer) and GPS during a drive, then derives the car's true forward acceleration via a 5 s gravity calibration, complementary-filter gravity tracking, and GPS-heading-based decomposition. All data stays on-device in a local SQLite database. Targets Android and iOS.

## Features

- Recording with 5 s calibration countdown, then continuous ~50 Hz sampling
- Recording history with filter chips (All / Dev / User), long-press multi-select, rename, delete
- Recording detail screen: summary cards, three time-series charts, data-quality badge, benchmarks
- Benchmarks: 0–100 km/h, 0–60 mph, 80–120 km/h, ¼ mile, max forward G per 20 km/h speed bucket, sudden-acceleration response from cruise
- Overlay comparison of two recordings on shared time axes, aligned at first movement
- Session metadata: per-recording car / drive-mode / passengers / fuel / tyre / weather, with reusable car profiles
- Versioned CSV / JSON export (share-sheet or save-to-file) and JSON import
- Light / dark / system theme; English / Hebrew (RTL) locale; dev-mode toggle
- Foreground location notification on Android keeps GPS streaming with the screen off

## Stack

- Flutter / Dart (`sdk: ^3.10.4`)
- Drift over SQLite (`sqlite3_flutter_libs`)
- Provider for state
- fl_chart for plots
- ARB-based localization (`flutter_localizations` / `flutter gen-l10n`)

See [.wiki/stack.md](.wiki/stack.md) for the full dependency list.

## Build & run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Test

```bash
flutter test
```

## Project documentation

The `.wiki/` directory is the source of truth for project knowledge. Start at [.wiki/index.md](.wiki/index.md).

## Continuous integration

Every push to `main` and every pull request runs `flutter analyze` + `flutter test` via [.github/workflows/ci.yml](.github/workflows/ci.yml).

## Release signing (Android)

The repository ships without a keystore. Debug builds and `flutter run` work out of the box; producing a signed release AAB requires a one-time setup:

1. Generate a keystore (do not commit it):

   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Copy `android/key.properties.template` to `android/key.properties` and fill in the four values. Both `key.properties` and `*.jks` are gitignored.
3. In [android/app/build.gradle.kts](android/app/build.gradle.kts), uncomment the `signingConfigs.release` and `buildTypes.release.signingConfig` blocks.
4. Build: `flutter build appbundle --release`.

## App icon

Placeholder source artwork lives at [assets/icon/](assets/icon/). After replacing `icon.png` with a 1024×1024 image, regenerate platform launcher icons:

```bash
dart run flutter_launcher_icons
```

## License

License: _TBD_
