import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/services/recording_engine.dart';

import '../helpers/fakes.dart';

/// Synthetic-input rig: a real [RecordingEngine] wired up to fakes that
/// expose `emit*` methods so tests can drive the engine through a known
/// driving scenario.
///
/// Convention used by all simulators in this file:
///   - Phone is calibrated flat (gravity along phone +Z).
///   - "Car forward" maps to phone +X. After the heading auto-calibrator
///     locks, the decomposer's forward axis lines up with phone +X.
///   - GPS heading is held at 0.0 (north).
class ScenarioRig {
  final RecordingEngine engine;
  final FakeRecordingStore store;
  final FakeSensorService sensor;
  final FakeGpsService gps;
  late final DateTime startTime;
  ScenarioRig._(this.engine, this.store, this.sensor, this.gps);

  static Future<ScenarioRig> start() async {
    final store = FakeRecordingStore();
    final sensor = FakeSensorService();
    final gps = FakeGpsService();
    final engine = RecordingEngine(
      db: store,
      sensorService: sensor,
      gpsService: gps,
    )
      ..flushInterval = Duration.zero
      ..useCalibrationTimer = false;

    await engine.startRecording(name: 'Scenario', isDev: false);
    sensor.emitAccel(0.0, 0.0, gravity, DateTime.now());
    await engine.finishCalibrationNow();

    final rig = ScenarioRig._(engine, store, sensor, gps);
    rig.startTime = store.insertedRecordings.single.startedAt.value;
    return rig;
  }

  Future<List<SensorSample>> stopAndGetSamples() async {
    await engine.stopRecording();
    final out = <SensorSample>[];
    for (var i = 0; i < store.insertedSamples.length; i++) {
      out.add(_companionToSample(store.insertedSamples[i], i + 1));
    }
    return out;
  }
}

const double gravity = 9.81;

SensorSample _companionToSample(SensorSamplesCompanion c, int id) {
  return SensorSample(
    id: id,
    recordingId: c.recordingId.value,
    timestampUs: c.timestampUs.value,
    accelX: c.accelX.value,
    accelY: c.accelY.value,
    accelZ: c.accelZ.value,
    linearAccelX: c.linearAccelX.value,
    linearAccelY: c.linearAccelY.value,
    linearAccelZ: c.linearAccelZ.value,
    gyroX: c.gyroX.value,
    gyroY: c.gyroY.value,
    gyroZ: c.gyroZ.value,
    forwardAccel: c.forwardAccel.value,
    lateralAccel: c.lateralAccel.value,
    gpsSpeed: c.gpsSpeed.value,
    gpsLat: c.gpsLat.value,
    gpsLon: c.gpsLon.value,
    gpsHeading: c.gpsHeading.value,
    gpsAltitude: c.gpsAltitude.value,
    gpsAccuracy: c.gpsAccuracy.value,
    gpsBearing: c.gpsBearing.value,
    gravX: c.gravX.value,
    gravY: c.gravY.value,
    gravZ: c.gravZ.value,
    pressure: c.pressure.value,
    quatW: c.quatW.value,
    quatX: c.quatX.value,
    quatY: c.quatY.value,
    quatZ: c.quatZ.value,
  );
}

/// Constant-forward-acceleration scenario: car pulls at [accelG] for
/// [durationSec] starting from [initialSpeedMps].
///
/// Emits raw-accel at [accelHz], GPS at [gpsHz]. GPS heading is 0
/// (north); phone +X carries the forward-accel component, +Z carries
/// gravity.
void simulateConstantAccel({
  required ScenarioRig rig,
  required double accelG,
  required double durationSec,
  double initialSpeedMps = 0,
  int accelHz = 50,
  int gpsHz = 10,
}) {
  final aMps = accelG * gravity;
  final accelStepUs = (1e6 / accelHz).round();
  final samplesPerGps = accelHz ~/ gpsHz;
  final total = (durationSec * accelHz).round();
  for (var i = 0; i < total; i++) {
    final t =
        rig.startTime.add(Duration(microseconds: i * accelStepUs));
    if (i % samplesPerGps == 0) {
      final speed = initialSpeedMps + aMps * (i / accelHz);
      rig.gps.emit(speed: speed, heading: 0.0, timestamp: t);
    }
    rig.sensor.emitAccel(aMps, 0.0, gravity, t);
  }
}

/// Hard-brake scenario: car decelerates at [brakeG] from [initialSpeedMps].
/// Phone -X carries the (negative) forward component; gravity stays on +Z.
/// GPS speed is clamped at 0.
void simulateBraking({
  required ScenarioRig rig,
  required double brakeG,
  required double initialSpeedMps,
  required double durationSec,
  int accelHz = 50,
  int gpsHz = 10,
}) {
  final aMps = brakeG * gravity;
  final accelStepUs = (1e6 / accelHz).round();
  final samplesPerGps = accelHz ~/ gpsHz;
  final total = (durationSec * accelHz).round();
  for (var i = 0; i < total; i++) {
    final t =
        rig.startTime.add(Duration(microseconds: i * accelStepUs));
    if (i % samplesPerGps == 0) {
      final speed = initialSpeedMps - aMps * (i / accelHz);
      rig.gps.emit(
        speed: speed < 0 ? 0 : speed,
        heading: 0.0,
        timestamp: t,
      );
    }
    rig.sensor.emitAccel(-aMps, 0.0, gravity, t);
  }
}

/// Steady-cruise scenario: phone reads pure gravity, GPS reports a
/// constant [speedMps] at heading 0.
void simulateSteadyCruise({
  required ScenarioRig rig,
  required double speedMps,
  required double durationSec,
  int accelHz = 50,
  int gpsHz = 10,
}) {
  final accelStepUs = (1e6 / accelHz).round();
  final samplesPerGps = accelHz ~/ gpsHz;
  final total = (durationSec * accelHz).round();
  for (var i = 0; i < total; i++) {
    final t =
        rig.startTime.add(Duration(microseconds: i * accelStepUs));
    if (i % samplesPerGps == 0) {
      rig.gps.emit(speed: speedMps, heading: 0.0, timestamp: t);
    }
    rig.sensor.emitAccel(0.0, 0.0, gravity, t);
  }
}

/// Alternating accel / brake bursts at [magnitudeG] g over [durationSec].
/// [periodSec] is the duration of one accel-then-brake cycle. Speed
/// oscillates around [centerSpeedMps].
void simulateAlternatingAccelBrake({
  required ScenarioRig rig,
  required double magnitudeG,
  required double durationSec,
  required double periodSec,
  double centerSpeedMps = 10.0,
  int accelHz = 50,
  int gpsHz = 10,
}) {
  final aMps = magnitudeG * gravity;
  final accelStepUs = (1e6 / accelHz).round();
  final samplesPerGps = accelHz ~/ gpsHz;
  final total = (durationSec * accelHz).round();
  final halfPeriodSamples = (periodSec * accelHz / 2).round();
  var speed = centerSpeedMps;
  for (var i = 0; i < total; i++) {
    final t =
        rig.startTime.add(Duration(microseconds: i * accelStepUs));
    final phase = (i ~/ halfPeriodSamples) % 2;
    final accelSigned = phase == 0 ? aMps : -aMps;
    speed += accelSigned * (1.0 / accelHz);
    if (speed < 1.0) speed = 1.0;
    if (i % samplesPerGps == 0) {
      rig.gps.emit(speed: speed, heading: 0.0, timestamp: t);
    }
    rig.sensor.emitAccel(accelSigned, 0.0, gravity, t);
  }
}
