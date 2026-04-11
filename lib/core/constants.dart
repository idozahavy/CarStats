class SensorConstants {
  static const int accelerometerSamplingMs = 20; // ~50 Hz
  static const int gpsSamplingMs = 1000; // 1 Hz
  static const int calibrationDurationSeconds = 5;
  static const int calibrationSampleCount = 250; // 5s * 50Hz
  static const double gpsMinSpeedForHeading = 2.0; // m/s — below this GPS heading is unreliable
}

class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String devMode = 'dev_mode';
}
