import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
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
  final _serviceLostController = StreamController<void>.broadcast();

  Stream<GpsReading> get gpsStream => _gpsController.stream;

  /// Fires when the underlying position stream errors mid-recording —
  /// typically because location permission was revoked or the system
  /// location service was disabled.
  Stream<void> get serviceLost => _serviceLostController.stream;

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

    final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'AccelStats Recording',
          notificationText: 'Recording GPS data in background',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // pauseLocationUpdatesAutomatically: false + otherNavigation prevents
      // iOS from killing the GPS stream when the screen locks.
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        _gpsController.add(GpsReading(
          latitude: position.latitude,
          longitude: position.longitude,
          speed: position.speed < 0 ? 0 : position.speed,
          heading: position.heading,
          altitude: position.altitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        ));
      },
      onError: (Object _) {
        if (!_serviceLostController.isClosed) {
          _serviceLostController.add(null);
        }
      },
    );
  }

  void stopListening() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void dispose() {
    stopListening();
    _gpsController.close();
    _serviceLostController.close();
  }
}
