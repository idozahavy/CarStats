import 'package:accel_stats/core/theme.dart';
import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/l10n/app_localizations.dart';
import 'package:accel_stats/services/recording_engine.dart';
import 'package:accel_stats/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

/// Pumps [child] wrapped in MaterialApp + all providers the app needs.
///
/// Returns a [TestHarness] giving access to the injected fakes so tests
/// can assert on them.
Future<TestHarness> pumpApp(
  WidgetTester tester,
  Widget child, {
  FakeDatabase? db,
  FakeRecordingStore? store,
  FakeSensorService? sensorService,
  FakeGpsService? gpsService,
  Map<String, Object>? prefsData,
  Locale? locale,
}) async {
  SharedPreferences.setMockInitialValues(prefsData ?? {});
  final prefs = await SharedPreferences.getInstance();

  final fakeDb = db ?? FakeDatabase();
  final fakeSensor = sensorService ?? FakeSensorService();
  final fakeGps = gpsService ?? FakeGpsService();
  final effectiveStore = store ?? fakeDb;

  final engine = RecordingEngine(
    db: effectiveStore,
    sensorService: fakeSensor,
    gpsService: fakeGps,
  )
    ..flushInterval = Duration.zero
    ..useCalibrationTimer = false;

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<RecordingStore>.value(value: fakeDb),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider<RecordingEngine>.value(value: engine),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale ?? const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );

  addTearDown(() async {
    await engine.stopRecording();
    engine.dispose();
  });

  return TestHarness(
    db: fakeDb,
    sensorService: fakeSensor,
    gpsService: fakeGps,
    engine: engine,
    prefs: prefs,
  );
}

class TestHarness {
  final FakeDatabase db;
  final FakeSensorService sensorService;
  final FakeGpsService gpsService;
  final RecordingEngine engine;
  final SharedPreferences prefs;

  TestHarness({
    required this.db,
    required this.sensorService,
    required this.gpsService,
    required this.engine,
    required this.prefs,
  });
}
