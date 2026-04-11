import 'dart:async';

import 'package:car_stats/data/database/database.dart';
import 'package:car_stats/services/gps_service.dart';
import 'package:car_stats/services/recording_engine.dart';
import 'package:car_stats/services/sensor_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRecordingStore implements RecordingStore {
  final List<RecordingsCompanion> insertedRecordings = [];
  final List<RecordingsCompanion> updatedRecordings = [];
  final List<SensorSamplesCompanion> insertedSamples = [];
  final List<int> deletedRecordingIds = [];

  int _nextId = 1;

  @override
  Future<int> insertRecording(RecordingsCompanion entry) async {
    insertedRecordings.add(entry);
    return _nextId++;
  }

  @override
  Future<void> updateRecording(RecordingsCompanion entry) async {
    updatedRecordings.add(entry);
  }

  @override
  Future<void> deleteRecording(int id) async {
    deletedRecordingIds.add(id);
  }

  @override
  Future<void> insertSensorSamplesBatch(
    List<SensorSamplesCompanion> entries,
  ) async {
    insertedSamples.addAll(entries);
  }
}

class FakeSensorService extends SensorService {
  final StreamController<AccelerometerReading> _accelController =
      StreamController<AccelerometerReading>.broadcast(sync: true);
  final StreamController<LinearAccelerometerReading> _linearAccelController =
      StreamController<LinearAccelerometerReading>.broadcast(sync: true);
  final StreamController<GyroscopeReading> _gyroController =
      StreamController<GyroscopeReading>.broadcast(sync: true);

  @override
  Stream<AccelerometerReading> get accelerometerStream =>
      _accelController.stream;

  @override
  Stream<LinearAccelerometerReading> get linearAccelerometerStream =>
      _linearAccelController.stream;

  @override
  Stream<GyroscopeReading> get gyroscopeStream => _gyroController.stream;

  @override
  void startListening() {}

  @override
  void stopListening() {}

  @override
  void dispose() {
    _accelController.close();
    _linearAccelController.close();
    _gyroController.close();
  }

  void emitAccel(double x, double y, double z, DateTime timestamp) {
    _accelController.add(AccelerometerReading(x, y, z, timestamp));
  }
}

class FakeGpsService extends GpsService {
  final StreamController<GpsReading> _gpsController =
      StreamController<GpsReading>.broadcast(sync: true);

  @override
  Stream<GpsReading> get gpsStream => _gpsController.stream;

  @override
  void startListening() {}

  @override
  void stopListening() {}

  @override
  void dispose() {
    _gpsController.close();
  }

  void emit({
    required double speed,
    required double heading,
    required DateTime timestamp,
  }) {
    _gpsController.add(
      GpsReading(
        latitude: 0,
        longitude: 0,
        speed: speed,
        heading: heading,
        altitude: 0,
        accuracy: 1,
        timestamp: timestamp,
      ),
    );
  }
}

Future<DateTime> _advanceToRecording(
  RecordingEngine engine,
  FakeRecordingStore store,
  FakeSensorService sensorService,
) async {
  await engine.startRecording(name: 'Test Run', isDev: false);
  sensorService.emitAccel(0.0, 0.0, 9.81, DateTime.now());
  await engine.finishCalibrationNow();

  expect(engine.state, RecordingState.recording);
  expect(store.insertedRecordings, hasLength(1));
  return store.insertedRecordings.single.startedAt.value;
}

void main() {
  group('RecordingEngine', () {
    test('stopping during calibration does not persist a recording', () async {
      final store = FakeRecordingStore();
      final sensorService = FakeSensorService();
      final gpsService = FakeGpsService();
      final engine = RecordingEngine(
        db: store,
        sensorService: sensorService,
        gpsService: gpsService,
      );

      await engine.startRecording(name: 'Test Run', isDev: false);

      expect(engine.state, RecordingState.calibrating);
      expect(store.insertedRecordings, isEmpty);

      await engine.stopRecording();

      expect(engine.state, RecordingState.idle);
      expect(store.insertedRecordings, isEmpty);
      expect(store.updatedRecordings, isEmpty);
      expect(store.insertedSamples, isEmpty);
    });

    test(
      'forward acceleration stays hidden until heading calibration locks',
      () async {
        final store = FakeRecordingStore();
        final sensorService = FakeSensorService();
        final gpsService = FakeGpsService();
        final engine = RecordingEngine(
          db: store,
          sensorService: sensorService,
          gpsService: gpsService,
        );

        final startTime = await _advanceToRecording(
          engine,
          store,
          sensorService,
        );

        gpsService.emit(speed: 5.0, heading: 0.0, timestamp: startTime);
        sensorService.emitAccel(
          2.0,
          0.0,
          9.81,
          startTime.add(const Duration(milliseconds: 100)),
        );

        expect(engine.latestSnapshot, isNotNull);
        expect(engine.latestSnapshot!.headingCalibrated, isFalse);
        expect(engine.latestSnapshot!.forwardAccelG, isNull);

        var speed = 5.0;
        for (var index = 0; index < 8; index++) {
          final sampleTime = startTime.add(
            Duration(milliseconds: 200 + (index * 100)),
          );
          sensorService.emitAccel(2.0, 0.0, 9.81, sampleTime);
          speed += 1.0;
          gpsService.emit(speed: speed, heading: 0.0, timestamp: sampleTime);
        }

        sensorService.emitAccel(
          2.0,
          0.0,
          9.81,
          startTime.add(const Duration(milliseconds: 1100)),
        );

        expect(engine.latestSnapshot, isNotNull);
        expect(engine.latestSnapshot!.headingCalibrated, isTrue);
        expect(engine.latestSnapshot!.forwardAccelG, closeTo(2.0 / 9.81, 0.05));
      },
    );

    test(
      'sample timing uses sensor timestamps and saved speed is clamped',
      () async {
        final store = FakeRecordingStore();
        final sensorService = FakeSensorService();
        final gpsService = FakeGpsService();
        final engine = RecordingEngine(
          db: store,
          sensorService: sensorService,
          gpsService: gpsService,
        );

        final startTime = await _advanceToRecording(
          engine,
          store,
          sensorService,
        );
        final sampleTime = startTime.add(const Duration(milliseconds: 250));

        gpsService.emit(speed: 0.3, heading: 0.0, timestamp: sampleTime);
        sensorService.emitAccel(0.0, 0.0, 9.81, sampleTime);

        expect(engine.latestSnapshot, isNotNull);
        expect(engine.latestSnapshot!.elapsedMs, 250);
        expect(engine.latestSnapshot!.gpsSpeedKmh, 0.0);

        await engine.stopRecording();

        expect(store.insertedSamples, hasLength(1));
        expect(store.insertedSamples.single.timestampUs.value, 250000);
        expect(store.insertedSamples.single.gpsSpeed.value, 0.0);
      },
    );
  });
}
