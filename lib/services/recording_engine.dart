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

enum RecordingWarning { gpsServiceLost }

class RecordingSnapshot {
  final double? gpsSpeedKmh;
  final double? forwardAccelG;
  final double? lateralAccelG;
  final double? pitchDeg;
  final double? rollDeg;
  final bool headingCalibrated;
  final int elapsedMs;
  final double peakForwardG;
  final double peakBrakeG;
  final double peakLateralG;

  RecordingSnapshot({
    this.gpsSpeedKmh,
    this.forwardAccelG,
    this.lateralAccelG,
    this.pitchDeg,
    this.rollDeg,
    this.headingCalibrated = false,
    required this.elapsedMs,
    this.peakForwardG = 0,
    this.peakBrakeG = 0,
    this.peakLateralG = 0,
  });
}

class RecordingEngine extends ChangeNotifier {
  final RecordingStore _db;
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
  StreamSubscription? _barometerSub;
  StreamSubscription? _serviceLostSub;
  Timer? _calibrationTimer;

  /// Set when recording is auto-stopped due to a transient failure (e.g. GPS
  /// permission revoked mid-session). The UI reads this once, maps it to a
  /// localised message, then clears it via [clearLastWarning].
  RecordingWarning? _lastWarning;
  RecordingWarning? get lastWarning => _lastWarning;

  // Latest raw values (for assembling combined samples)
  AccelerometerReading? _lastAccel;
  LinearAccelerometerReading? _lastLinearAccel;
  GyroscopeReading? _lastGyro;
  GpsReading? _lastGps;
  double? _lastBaroPressure;
  double? _gpsBearing;

  // Last gyro timestamp for dt calculation
  DateTime? _lastGyroTime;

  // Peak G tracking
  double _peakForwardG = 0;
  double _peakBrakeG = 0;
  double _peakLateralG = 0;

  String? _pendingRecordingName;
  bool _pendingIsDev = false;

  // Data points for live chart (capped for memory)
  static const int _maxSnapshots = 3000;
  final List<RecordingSnapshot> snapshots = [];

  // UI throttle — notify at most ~10Hz instead of 50Hz
  DateTime _lastNotify = DateTime(0);
  static const _notifyInterval = Duration(milliseconds: 100);

  /// Set to Duration.zero in tests to disable the periodic flush timer.
  @visibleForTesting
  Duration flushInterval = const Duration(seconds: 2);

  /// Set to false in tests to skip the calibration countdown timer.
  @visibleForTesting
  bool useCalibrationTimer = true;

  RecordingEngine({
    required RecordingStore db,
    required SensorService sensorService,
    required GpsService gpsService,
  }) : _db = db,
       _sensorService = sensorService,
       _gpsService = gpsService;

  /// Start the calibration countdown, then transition to recording.
  Future<void> startRecording({
    required String name,
    required bool isDev,
  }) async {
    if (_state != RecordingState.idle) return;

    // Set state immediately to prevent double-start from rapid taps
    _state = RecordingState.calibrating;

    _pendingRecordingName = name;
    _pendingIsDev = isDev;
    _currentRecordingId = null;
    _recordingStartTime = null;
    _latestSnapshot = null;
    _lastAccel = null;
    _lastLinearAccel = null;
    _lastGyro = null;
    _lastGps = null;
    _lastBaroPressure = null;
    _gpsBearing = null;
    _lastGyroTime = null;
    _peakForwardG = 0;
    _peakBrakeG = 0;
    _peakLateralG = 0;
    _lastNotify = DateTime(0);
    _sampleBuffer.clear();

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
    if (useCalibrationTimer) {
      _calibrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _calibrationCountdown--;
        notifyListeners();
        if (_calibrationCountdown <= 0) {
          timer.cancel();
          unawaited(_finishCalibration());
        }
      });
    }
  }

  void _onCalibrationAccel(AccelerometerReading reading) {
    _calibrationService.addSample(reading);
  }

  @visibleForTesting
  Future<void> finishCalibrationNow() => _finishCalibration();

  Future<void> _finishCalibration() async {
    if (_state != RecordingState.calibrating) return;

    _calibrationTimer?.cancel();
    _calibrationTimer = null;

    _accelSub?.cancel();
    _accelSub = null;

    _calibration = _calibrationService.compute();
    if (_calibration != null) {
      _decomposer = AccelerationDecomposer(_calibration!);
    } else {
      _decomposer = null;
    }

    final recordingName = _pendingRecordingName;
    if (recordingName == null) {
      _state = RecordingState.idle;
      notifyListeners();
      return;
    }

    final startTime = DateTime.now();
    final recordingId = await _db.insertRecording(
      RecordingsCompanion(
        name: Value(recordingName),
        startedAt: Value(startTime),
        isDevRecording: Value(_pendingIsDev),
      ),
    );

    if (_state != RecordingState.calibrating) {
      await _db.deleteRecording(recordingId);
      return;
    }

    _currentRecordingId = recordingId;
    _recordingStartTime = startTime;
    _pendingRecordingName = null;
    _pendingIsDev = false;
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
    _serviceLostSub = _gpsService.serviceLost.listen((_) {
      unawaited(_handleGpsServiceLost());
    });
    _barometerSub = _sensorService.barometerStream.listen(
      _onRecordingBarometer,
      onError: (_) {},
    );

    // Flush buffer periodically (disabled when flushInterval is zero)
    if (flushInterval > Duration.zero) {
      _flushTimer = Timer.periodic(
        flushInterval,
        (_) => _flushBuffer(),
      );
    }
  }

  void _onRecordingAccel(AccelerometerReading r) {
    _lastAccel = r;
    // Complementary filter: gently correct gravity axis when accel ≈ 9.81.
    _decomposer?.correctWithAccel(r.x, r.y, r.z);
    _assembleSample();
  }

  void _onRecordingLinearAccel(LinearAccelerometerReading r) {
    _lastLinearAccel = r;
  }

  void _onRecordingGyro(GyroscopeReading r) {
    _lastGyro = r;
    if (_decomposer != null && _lastGyroTime != null) {
      final dt = r.timestamp.difference(_lastGyroTime!).inMicroseconds / 1e6;
      if (dt > 0 && dt < 0.5) {
        _decomposer!.updateWithGyro(r.x, r.y, r.z, dt);
      }
    }
    _lastGyroTime = r.timestamp;
  }

  void _onRecordingGps(GpsReading r) {
    final prevSpeed = _lastGps?.speed;

    // Compute bearing between consecutive GPS points
    if (_lastGps != null) {
      _gpsBearing = _computeBearing(
        _lastGps!.latitude,
        _lastGps!.longitude,
        r.latitude,
        r.longitude,
      );
    }

    _lastGps = r;

    // Update heading for decomposer if speed is sufficient.
    // Filter out sentinel headings (geolocator emits negative values when
    // the device is stationary or has no compass fix) — feeding these into
    // the decomposer / heading calibrator would corrupt the estimate.
    final headingValid = r.heading >= 0 && r.heading <= 360;
    if (_decomposer != null &&
        r.speed >= SensorConstants.gpsMinSpeedForHeading &&
        headingValid) {
      final headingRad = r.heading * (pi / 180.0);
      _decomposer!.gpsHeadingRad = headingRad;

      // Feed speed delta to heading auto-calibrator
      if (prevSpeed != null) {
        _decomposer!.onGpsUpdate(headingRad, r.speed - prevSpeed);
      }
    }
  }

  void _onRecordingBarometer(BarometerReading r) {
    _lastBaroPressure = r.pressure;
  }

  Future<void> _handleGpsServiceLost() async {
    if (_state != RecordingState.recording &&
        _state != RecordingState.calibrating) {
      return;
    }
    _lastWarning = RecordingWarning.gpsServiceLost;
    await stopRecording();
    notifyListeners();
  }

  /// Consumed by the recording UI after surfacing the warning to the user.
  void clearLastWarning() {
    if (_lastWarning == null) return;
    _lastWarning = null;
    notifyListeners();
  }

  /// Compute initial bearing between two lat/lon points (Haversine forward azimuth).
  static double _computeBearing(
    double lat1Deg,
    double lon1Deg,
    double lat2Deg,
    double lon2Deg,
  ) {
    final lat1 = lat1Deg * (pi / 180.0);
    final lat2 = lat2Deg * (pi / 180.0);
    final dLon = (lon2Deg - lon1Deg) * (pi / 180.0);
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * (180.0 / pi);
    return (bearing + 360.0) % 360.0;
  }

  void _assembleSample() {
    final sampleTime = _lastAccel?.timestamp;
    if (_recordingStartTime == null ||
        _currentRecordingId == null ||
        sampleTime == null) {
      return;
    }

    final now = DateTime.now();
    final elapsedUs = sampleTime
        .difference(_recordingStartTime!)
        .inMicroseconds;
    if (elapsedUs < 0) return;

    // Compute forward and lateral acceleration
    double? forwardAccel;
    double? lateralAccel;
    final headingCalibrated = _decomposer?.isHeadingCalibrated ?? false;
    if (_decomposer != null && _lastAccel != null) {
      final decomposed = _decomposer!.decompose(
        _lastAccel!.x,
        _lastAccel!.y,
        _lastAccel!.z,
      );
      forwardAccel = decomposed[0];
      lateralAccel = decomposed[1];
    }

    final gpsSpeedMps = _lastGps?.speed;
    // Snap speed to 0 when below stationary threshold
    final effectiveSpeedMps =
        (gpsSpeedMps != null &&
            gpsSpeedMps < SensorConstants.gpsStationarySpeed)
        ? 0.0
        : gpsSpeedMps;
    final gpsSpeedKmh = effectiveSpeedMps != null
        ? effectiveSpeedMps * 3.6
        : null;

    // When stationary, clamp small accel to 0 (sensor noise)
    double? displayAccelG = forwardAccel != null ? forwardAccel / 9.81 : null;
    double? displayLateralG = lateralAccel != null ? lateralAccel / 9.81 : null;
    if (effectiveSpeedMps == 0.0) {
      if (displayAccelG != null &&
          displayAccelG.abs() < SensorConstants.accelNoiseFloor) {
        displayAccelG = 0.0;
      }
      if (displayLateralG != null &&
          displayLateralG.abs() < SensorConstants.accelNoiseFloor) {
        displayLateralG = 0.0;
      }
    }

    // Update peak G values
    if (displayAccelG != null) {
      if (displayAccelG > _peakForwardG) _peakForwardG = displayAccelG;
      if (displayAccelG < _peakBrakeG) _peakBrakeG = displayAccelG;
    }
    if (displayLateralG != null) {
      if (displayLateralG.abs() > _peakLateralG) {
        _peakLateralG = displayLateralG.abs();
      }
    }

    // Get phone orientation from decomposer
    double? pitchDeg;
    double? rollDeg;
    if (_decomposer != null) {
      final orient = _decomposer!.orientationDegrees;
      pitchDeg = orient[0];
      rollDeg = orient[1];
    }

    // Build snapshot for live display
    final snapshot = RecordingSnapshot(
      gpsSpeedKmh: gpsSpeedKmh,
      forwardAccelG: displayAccelG,
      lateralAccelG: displayLateralG,
      peakForwardG: _peakForwardG,
      peakBrakeG: _peakBrakeG,
      peakLateralG: _peakLateralG,
      pitchDeg: pitchDeg,
      rollDeg: rollDeg,
      headingCalibrated: headingCalibrated,
      elapsedMs: elapsedUs ~/ 1000,
    );
    _latestSnapshot = snapshot;
    snapshots.add(snapshot);

    // Cap snapshots list to prevent unbounded memory growth
    if (snapshots.length > _maxSnapshots) {
      snapshots.removeRange(0, snapshots.length - _maxSnapshots);
    }

    // Build DB entry
    final gravVec = _decomposer?.gravityVector;
    final quat = _decomposer?.quaternion;
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
      lateralAccel: Value(lateralAccel),
      gpsSpeed: Value(effectiveSpeedMps),
      gpsLat: Value(_lastGps?.latitude),
      gpsLon: Value(_lastGps?.longitude),
      gpsHeading: Value(_lastGps?.heading),
      gpsAltitude: Value(_lastGps?.altitude),
      gpsAccuracy: Value(_lastGps?.accuracy),
      gpsBearing: Value(_gpsBearing),
      gravX: Value(gravVec?[0]),
      gravY: Value(gravVec?[1]),
      gravZ: Value(gravVec?[2]),
      pressure: Value(_lastBaroPressure),
      quatW: Value(quat?[0]),
      quatX: Value(quat?[1]),
      quatY: Value(quat?[2]),
      quatZ: Value(quat?[3]),
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
    if (_state != RecordingState.recording &&
        _state != RecordingState.calibrating) {
      return;
    }

    final hadRecording =
        _currentRecordingId != null && _recordingStartTime != null;

    _calibrationTimer?.cancel();
    _flushTimer?.cancel();
    _accelSub?.cancel();
    _linearAccelSub?.cancel();
    _gyroSub?.cancel();
    _gpsSub?.cancel();
    _barometerSub?.cancel();
    _serviceLostSub?.cancel();
    _serviceLostSub = null;

    _sensorService.stopListening();
    _gpsService.stopListening();

    // Flush remaining samples
    await _flushBuffer();

    // Update recording end time
    if (hadRecording) {
      final now = DateTime.now();
      await _db.updateRecording(
        RecordingsCompanion(
          id: Value(_currentRecordingId!),
          endedAt: Value(now),
          durationMs: Value(
            now.difference(_recordingStartTime!).inMilliseconds,
          ),
        ),
      );
      _state = RecordingState.stopped;
    } else {
      _pendingRecordingName = null;
      _pendingIsDev = false;
      _state = RecordingState.idle;
    }
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
    _lastBaroPressure = null;
    _gpsBearing = null;
    _lastGyroTime = null;
    _peakForwardG = 0;
    _peakBrakeG = 0;
    _peakLateralG = 0;
    _pendingRecordingName = null;
    _pendingIsDev = false;
    _lastNotify = DateTime(0);
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
