# Phase 10 — Project Infrastructure

## Goal
Project hygiene: a real README, a CHANGELOG, GitHub Actions for analyze + test, app launcher icons (placeholder artwork), and signing-config documentation for Android release.

## Context primer

**Project**: AccelStats — Flutter app recording phone sensors + GPS to derive a car's forward acceleration. Two-table SQLite via Drift, Provider state, fl_chart visualisation. Android + iOS only.

**Working directory**: `c:\Users\idoza\Documents\GitHub\CarStats`

**Wiki entry points**: read `.wiki/index.md` first. Then `.wiki/architecture.md`, `.wiki/stack.md`.

**Code layout**:
- `README.md` — currently near-empty (default Flutter README)
- `pubspec.yaml` — version, dependencies
- `android/` — Android Gradle project; release signing config typically goes in `android/app/build.gradle` referencing `key.properties`
- `ios/` — iOS Xcode project; signing handled in Xcode (out of scope)
- `.github/` — does not exist yet; CI workflows will go in `.github/workflows/`

**Hard rules**:
- Read a file before modifying it.
- Update wiki per `.wiki/SCHEMA.md`.
- Do NOT generate or commit any actual signing keystore. Only commit a `key.properties.template` and document the workflow.

## Decisions already made (do not relitigate)

- **App icon**: generate a placeholder via `flutter_launcher_icons` from a simple speedometer SVG/PNG you create programmatically. The user will replace artwork later.
- **Signing**: docs + `key.properties.template` only. No keystore, no upload.
- **CI**: GitHub Actions workflow that runs `flutter pub get`, `flutter analyze`, `flutter test` on `pull_request` and `push` to `main`. Uses `subosito/flutter-action` to install Flutter.
- **CHANGELOG**: keep-a-changelog format, ASCII only. Initial entry summarises everything since project start by reading `.wiki/log.md` and `git log --oneline`.

## Scope

**In:**
- README rewrite (purpose, features, screenshots placeholder, build/run, contributing pointer to `.wiki/`)
- `CHANGELOG.md` at project root
- `.github/workflows/ci.yml` — analyze + test
- `flutter_launcher_icons` setup + placeholder PNG
- `android/key.properties.template` + signing block in `android/app/build.gradle` (commented out, with instructions)
- Documentation block in README explaining how to enable release signing

**Out:**
- Actual keystore generation
- Play Store/App Store metadata
- Translation of README
- Anything that requires secrets in CI

## Tasks (ordered)

### A. README
File: `README.md`

1. Replace contents with the following structure. Keep it short and accurate — pull facts from `.wiki/architecture.md` and `.wiki/stack.md`, do not invent.
   - **AccelStats** — one-paragraph description (car acceleration measurement using phone sensors + GPS)
   - **Features** — bullet list (recording with 5 s calibration, history list with filtering, CSV/JSON export and JSON import, light/dark theme, dev mode, English + Hebrew, session metadata, benchmarks, overlay comparison) — adjust based on what has actually shipped at this point in the phase order.
   - **Stack** — Flutter (Dart `^3.10.4`), Drift/SQLite, Provider, fl_chart. Targets Android + iOS.
   - **Build & run** — `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter run`
   - **Test** — `flutter test`
   - **Project documentation** — pointer to `.wiki/index.md`
   - **Release signing** — pointer to the section added in step E.
   - **License** — leave as `_TBD_` if no license is currently declared.

### B. CHANGELOG
File: `CHANGELOG.md`

1. Use [keep-a-changelog](https://keepachangelog.com/en/1.1.0/) format. Initial structure:
   ```
   # Changelog
   All notable changes to this project will be documented in this file.

   The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
   and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

   ## [Unreleased]

   ## [0.1.0] - <today>
   ### Added
   - <pull from .wiki/log.md and git log>
   ```
2. Read `.wiki/log.md` and the most recent ~30 commits via `git log --oneline -30`. Synthesise an "Added" / "Changed" / "Fixed" breakdown for the 0.1.0 entry. Be honest — only list what is actually in the codebase.

### C. GitHub Actions CI
File: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test
```

Verify the workflow file is syntactically valid YAML (Actions will fail fast if not).

### D. Launcher icons
1. Add `flutter_launcher_icons` to `dev_dependencies` in `pubspec.yaml`.
2. Create a placeholder source PNG at `assets/icon/icon.png` — 1024×1024, simple dark-blue background with a white speedometer-needle glyph. If you cannot generate a PNG programmatically without extra dependencies, document the gap: leave a `assets/icon/README.md` with a one-line "Add 1024×1024 icon.png here, then run `dart run flutter_launcher_icons`."
3. Add to `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/icon.png"
     min_sdk_android: 21
   ```
4. Run `dart run flutter_launcher_icons` if the PNG exists. Otherwise document the manual step in the README.

### E. Android release signing
Files: `android/key.properties.template`, `android/app/build.gradle`, README

1. Create `android/key.properties.template`:
   ```
   storePassword=
   keyPassword=
   keyAlias=
   storeFile=
   ```
2. In `android/app/build.gradle`, add (commented out by default to keep `flutter run` working without a keystore):
   ```gradle
   // To enable release signing:
   // 1. Copy key.properties.template to key.properties (gitignored)
   // 2. Generate keystore: keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   // 3. Fill key.properties
   // 4. Uncomment the signingConfigs and buildTypes blocks below
   //
   // def keystoreProperties = new Properties()
   // def keystorePropertiesFile = rootProject.file('key.properties')
   // if (keystorePropertiesFile.exists()) {
   //     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   // }
   //
   // android {
   //     signingConfigs { release { ... } }
   //     buildTypes { release { signingConfig signingConfigs.release } }
   // }
   ```
3. Add `key.properties` and `*.jks` to `android/.gitignore` (or root `.gitignore`).
4. Document the workflow under "Release signing" in README.

### F. Verify
- `flutter analyze` — clean
- `flutter test` — all green
- `.github/workflows/ci.yml` is valid YAML
- `flutter pub get` succeeds with the new dev dependency
- README renders correctly on GitHub (preview locally if possible — at minimum verify markdown structure)

### G. Wiki updates
- `.wiki/stack.md` — add `flutter_launcher_icons` (dev), document CI under Commands or a new "CI" subsection.
- `.wiki/conventions.md` — add a brief "CI" subsection pointing to `.github/workflows/ci.yml` and stating the quality gate (analyze + test on every PR).
- `.wiki/log.md` — append dated entry.

## Acceptance criteria

- `README.md` describes the app, features, build commands, test command, and pointer to wiki — not the default Flutter README
- `CHANGELOG.md` exists with at least one dated version entry
- `.github/workflows/ci.yml` exists; running it on a feature branch passes
- `flutter_launcher_icons` is configured in `pubspec.yaml` and produces icons (or a documented manual step exists if no source PNG could be generated)
- `android/key.properties.template` exists; signing instructions in README
- `key.properties` and `*.jks` are gitignored
- All existing tests still pass; analyzer clean
- Wiki updated and `Last verified` bumped

## Wiki updates required

- `.wiki/stack.md`
- `.wiki/conventions.md`
- `.wiki/log.md` (append entry)
