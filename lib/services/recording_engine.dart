import 'dart:async';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../data/database/database.dart';
import 'calibration_service.dart';
import 'gps_service.dart';
import 'sensor_service.dart';

enum RecordingState { idle, calibrating, recording, stopped }

class RecordingSnapshot {
  final double? gpsSpeedKmh;
  final double? forwardAccelG;
  final double? linearAccelMagnitude;
  final int elapsedMs;

  RecordingSnapshot({
    this.gpsSpeedKmh,
    this.forwardAccelG,
    this.linearAccelMagnitude,
    required this.elapsedMs,
  });
}

class RecordingEngine extends ChangeNotifier {
  final AppDatabase _db;
  final SensorService _sensorService;
  final GpsService _gpsService;

  RecordingState _state = RecordingState.idle;
  RecordingState get state => _state;

  int? _currentRecordingId;
  int? get currentRecordingId => _currentRecordingId;

  DateTime? _recordingStartTime;

  // Calibration
  final CalibrationService _calibrationService = CalibrationService();
  CalibrationResult? _calibration;
  AccelerationDecomposer? _decomposer;
  int _calibrationCountdown = SensorConstants.calibrationDurationSeconds;
  int get calibrationCountdown => _calibrationCountdown;

  // Latest values for live display
  RecordingSnapshot? _latestSnapshot;
  RecordingSnapshot? get latestSnapshot => _latestSnapshot;

  // Buffered samples for batch insert
  final List<SensorSamplesCompanion> _sampleBuffer = [];
  Timer? _flushTimer;

  // Stream subscriptions
  StreamSubscription? _accelSub;
  StreamSubscription? _linearAccelSub;
  StreamSubscription? _gyroSub;
  StreamSubscription? _gpsSub;
  Timer? _calibrationTimer;

  // Latest raw values (for assembling combined samples)
  AccelerometerReading? _lastAccel;
  LinearAccelerometerReading? _lastLinearAccel;
  GyroscopeReading? _lastGyro;
  GpsReading? _lastGps;

  // Dev mode
  bool devMode;

  // Data points for live chart (capped for memory)
  static const int _maxSnapshots = 3000;
  final List<RecordingSnapshot> snapshots = [];

  // UI throttle — notify at most ~10Hz instead of 50Hz
  DateTime _lastNotify = DateTime(0);
  static const _notifyInterval = Duration(milliseconds: 100);

  RecordingEngine({
    required AppDatabase db,
    required SensorService sensorService,
    required GpsService gpsService,
    this.devMode = false,
  })  : _db = db,
        _sensorService = sensorService,
        _gpsService = gpsService;

  /// Start the calibration countdown, then transition to recording.
  Future<void> startRecording({required String name, required bool isDev}) async {
    if (_state != RecordingState.idle) return;

    // Set state immediately to prevent double-start from rapid taps
    _state = RecordingState.calibrating;

    // Create DB record
    _currentRecordingId = await _db.insertRecording(RecordingsCompanion(
      name: Value(name),
      startedAt: Value(DateTime.now()),
      isDevRecording: Value(isDev),
    ));

    _calibrationService.reset();
    _calibrationCountdown = SensorConstants.calibrationDurationSeconds;
    snapshots.clear();
    notifyListeners();

    // Start sensors
    _sensorService.startListening();
    _gpsService.startListening();

    // Collect calibration samples
    _accelSub = _sensorService.accelerometerStream.listen(
      _onCalibrationAccel,
      onError: (_) {},
    );

    // Countdown timer
    _calibrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calibrationCountdown--;
      notifyListeners();
      if (_calibrationCountdown <= 0) {
        timer.cancel();
        _finishCalibration();
      }
    });
  }

  void _onCalibrationAccel(AccelerometerReading reading) {
    _calibrationService.addSample(reading);
  }

  void _finishCalibration() {
    _accelSub?.cancel();

    _calibration = _calibrationService.compute();
    if (_calibration != null) {
      _decomposer = AccelerationDecomposer(_calibration!);
    }

    _recordingStartTime = DateTime.now();
    _state = RecordingState.recording;
    notifyListeners();

    // Subscribe to all streams for recording
    _accelSub = _sensorService.accelerometerStream.listen(
      _onRecordingAccel,
      onError: (_) {}, // sensor errors are non-fatal, skip sample
    );
    _linearAccelSub = _sensorService.linearAccelerometerStream.listen(
      _onRecordingLinearAccel,
      onError: (_) {},
    );
    _gyroSub = _sensorService.gyroscopeStream.listen(
      _onRecordingGyro,
      onError: (_) {},
    );
    _gpsSub = _gpsService.gpsStream.listen(
      _onRecordingGps,
      onError: (_) {}, // GPS dropout is expected (tunnels, etc.)
    );

    // Flush buffer periodically
    _flushTimer = Timer.periodic(const Duration(seconds: 2), (_) => _flushBuffer());
  }

  void _onRecordingAccel(AccelerometerReading r) {
    _lastAccel = r;
    _assembleSample();
  }

  void _onRecordingLinearAccel(LinearAccelerometerReading r) {
    _lastLinearAccel = r;
  }

  void _onRecordingGyro(GyroscopeReading r) {
    _lastGyro = r;
  }

  void _onRecordingGps(GpsReading r) {
    _lastGps = r;

    // Update heading for decomposer if speed is sufficient
    if (_decomposer != null && r.speed >= SensorConstants.gpsMinSpeedForHeading) {
      _decomposer!.gpsHeadingRad = r.heading * (pi / 180.0);
    }
  }

  void _assembleSample() {
    if (_recordingStartTime == null || _currentRecordingId == null) return;
    final now = DateTime.now();
    final elapsedUs = now.difference(_recordingStartTime!).inMicroseconds;

    // Compute forward acceleration
    double? forwardAccel;
    if (_decomposer != null && _lastAccel != null) {
      final decomposed = _decomposer!.decompose(
        _lastAccel!.x,
        _lastAccel!.y,
        _lastAccel!.z,
      );
      forwardAccel = decomposed[0];
    }

    final gpsSpeedMps = _lastGps?.speed;
    final gpsSpeedKmh = gpsSpeedMps != null ? gpsSpeedMps * 3.6 : null;

    // Build snapshot for live display
    final snapshot = RecordingSnapshot(
      gpsSpeedKmh: gpsSpeedKmh,
      forwardAccelG: forwardAccel != null ? forwardAccel / 9.81 : null,
      linearAccelMagnitude: _lastLinearAccel != null
          ? sqrt(_lastLinearAccel!.x * _lastLinearAccel!.x +
                _lastLinearAccel!.y * _lastLinearAccel!.y +
                _lastLinearAccel!.z * _lastLinearAccel!.z) /
              9.81
          : null,
      elapsedMs: elapsedUs ~/ 1000,
    );
    _latestSnapshot = snapshot;
    snapshots.add(snapshot);

    // Cap snapshots list to prevent unbounded memory growth
    if (snapshots.length > _maxSnapshots) {
      snapshots.removeRange(0, snapshots.length - _maxSnapshots);
    }

    // Build DB entry
    final sample = SensorSamplesCompanion(
      recordingId: Value(_currentRecordingId!),
      timestampUs: Value(elapsedUs),
      accelX: Value(_lastAccel?.x),
      accelY: Value(_lastAccel?.y),
      accelZ: Value(_lastAccel?.z),
      linearAccelX: Value(_lastLinearAccel?.x),
      linearAccelY: Value(_lastLinearAccel?.y),
      linearAccelZ: Value(_lastLinearAccel?.z),
      gyroX: Value(_lastGyro?.x),
      gyroY: Value(_lastGyro?.y),
      gyroZ: Value(_lastGyro?.z),
      forwardAccel: Value(forwardAccel),
      gpsSpeed: Value(gpsSpeedMps),
      gpsLat: Value(_lastGps?.latitude),
      gpsLon: Value(_lastGps?.longitude),
      gpsHeading: Value(_lastGps?.heading),
      gpsAltitude: Value(_lastGps?.altitude),
      gpsAccuracy: Value(_lastGps?.accuracy),
    );
    _sampleBuffer.add(sample);

    // Throttle UI rebuilds to ~10Hz instead of 50Hz
    if (now.difference(_lastNotify) >= _notifyInterval) {
      _lastNotify = now;
      notifyListeners();
    }
  }

  Future<void> _flushBuffer() async {
    if (_sampleBuffer.isEmpty) return;
    final toFlush = List<SensorSamplesCompanion>.from(_sampleBuffer);
    _sampleBuffer.clear();
    await _db.insertSensorSamplesBatch(toFlush);
  }

  Future<void> stopRecording() async {
    if (_state != RecordingState.recording && _state != RecordingState.calibrating) return;

    _calibrationTimer?.cancel();
    _accelSub?.cancel();
    _linearAccelSub?.cancel();
    _gyroSub?.cancel();
    _gpsSub?.cancel();
    _flushTimer?.cancel();

    _sensorService.stopListening();
    _gpsService.stopListening();

    // Flush remaining samples
    await _flushBuffer();

    // Update recording end time
    if (_currentRecordingId != null && _recordingStartTime != null) {
      final now = DateTime.now();
      await _db.updateRecording(RecordingsCompanion(
        id: Value(_currentRecordingId!),
        endedAt: Value(now),
        durationMs: Value(now.difference(_recordingStartTime!).inMilliseconds),
      ));
    }

    _state = RecordingState.stopped;
    notifyListeners();
  }

  void reset() {
    _state = RecordingState.idle;
    _currentRecordingId = null;
    _recordingStartTime = null;
    _calibration = null;
    _decomposer = null;
    _latestSnapshot = null;
    _lastAccel = null;
    _lastLinearAccel = null;
    _lastGyro = null;
    _lastGps = null;
    snapshots.clear();
    _sampleBuffer.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    stopRecording();
    super.dispose();
  }
}
