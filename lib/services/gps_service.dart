import 'dart:async';
import 'package:geolocator/geolocator.dart';

class GpsReading {
  final double latitude;
  final double longitude;
  final double speed; // m/s
  final double heading; // degrees
  final double altitude; // meters
  final double accuracy; // meters
  final DateTime timestamp;

  GpsReading({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.altitude,
    required this.accuracy,
    required this.timestamp,
  });
}

class GpsService {
  StreamSubscription<Position>? _positionSub;
  final _gpsController = StreamController<GpsReading>.broadcast();

  Stream<GpsReading> get gpsStream => _gpsController.stream;

  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  void startListening() {
    // Guard against double-subscription
    if (_positionSub != null) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen((position) {
      _gpsController.add(GpsReading(
        latitude: position.latitude,
        longitude: position.longitude,
        speed: position.speed < 0 ? 0 : position.speed,
        heading: position.heading,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      ));
    });
  }

  void stopListening() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void dispose() {
    stopListening();
    _gpsController.close();
  }
}
