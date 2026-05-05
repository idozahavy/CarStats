# Launcher icon source

`icon.png` is the source artwork consumed by `flutter_launcher_icons` to generate platform-specific launcher icons. It must be a 1024×1024 PNG.

The current file is a placeholder (dark navy background, white speedometer dial, red needle, white hub). Replace it with final artwork before release.

## Regenerate platform icons

```bash
dart run flutter_launcher_icons
```

This rewrites the per-density Android mipmap drawables and the iOS `AppIcon.appiconset` from `icon.png`. The configuration block lives at the bottom of [pubspec.yaml](../../pubspec.yaml).
