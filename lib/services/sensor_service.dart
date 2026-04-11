import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerReading {
  final double x, y, z;
  final DateTime timestamp;
  AccelerometerReading(this.x, this.y, this.z, this.timestamp);
}

class LinearAccelerometerReading {
  final double x, y, z;
  final DateTime timestamp;
  LinearAccelerometerReading(this.x, this.y, this.z, this.timestamp);
}

class GyroscopeReading {
  final double x, y, z;
  final DateTime timestamp;
  GyroscopeReading(this.x, this.y, this.z, this.timestamp);
}

class BarometerReading {
  final double pressure; // hPa
  final DateTime timestamp;
  BarometerReading(this.pressure, this.timestamp);
}

class SensorService {
  StreamSubscription? _accelSub;
  StreamSubscription? _linearAccelSub;
  StreamSubscription? _gyroSub;
  StreamSubscription? _barometerSub;

  final _accelController = StreamController<AccelerometerReading>.broadcast();
  final _linearAccelController =
      StreamController<LinearAccelerometerReading>.broadcast();
  final _gyroController = StreamController<GyroscopeReading>.broadcast();
  final _barometerController = StreamController<BarometerReading>.broadcast();

  Stream<AccelerometerReading> get accelerometerStream =>
      _accelController.stream;
  Stream<LinearAccelerometerReading> get linearAccelerometerStream =>
      _linearAccelController.stream;
  Stream<GyroscopeReading> get gyroscopeStream => _gyroController.stream;
  Stream<BarometerReading> get barometerStream => _barometerController.stream;

  static const _samplingDuration = Duration(milliseconds: 20);

  void startListening() {
    // Guard against double-subscription
    if (_accelSub != null) return;

    _accelSub = accelerometerEventStream(samplingPeriod: _samplingDuration)
        .listen((event) {
          _accelController.add(
            AccelerometerReading(event.x, event.y, event.z, event.timestamp),
          );
        });

    _linearAccelSub =
        userAccelerometerEventStream(samplingPeriod: _samplingDuration).listen((
          event,
        ) {
          _linearAccelController.add(
            LinearAccelerometerReading(
              event.x,
              event.y,
              event.z,
              event.timestamp,
            ),
          );
        });

    _gyroSub = gyroscopeEventStream(samplingPeriod: _samplingDuration).listen((
      event,
    ) {
      _gyroController.add(
        GyroscopeReading(event.x, event.y, event.z, event.timestamp),
      );
    });

    _barometerSub =
        barometerEventStream(samplingPeriod: const Duration(seconds: 1)).listen(
          (event) {
            _barometerController.add(
              BarometerReading(event.pressure, event.timestamp),
            );
          },
          onError: (_) {}, // barometer may not be available on all devices
        );
  }

  void stopListening() {
    _accelSub?.cancel();
    _linearAccelSub?.cancel();
    _gyroSub?.cancel();
    _barometerSub?.cancel();
    _accelSub = null;
    _linearAccelSub = null;
    _gyroSub = null;
    _barometerSub = null;
  }

  void dispose() {
    stopListening();
    _accelController.close();
    _linearAccelController.close();
    _gyroController.close();
    _barometerController.close();
  }
}

/// Utility to compute magnitude of a 3D vector.
double vectorMagnitude(double x, double y, double z) {
  return sqrt(x * x + y * y + z * z);
}
