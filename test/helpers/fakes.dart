import 'dart:async';

import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/services/gps_service.dart';
import 'package:accel_stats/services/sensor_service.dart';

class FakeRecordingStore implements RecordingStore {
  final List<RecordingsCompanion> insertedRecordings = [];
  final List<RecordingsCompanion> updatedRecordings = [];
  final List<SensorSamplesCompanion> insertedSamples = [];
  final List<int> deletedRecordingIds = [];
  final List<({int id, String name})> renamedRecordings = [];
  final List<CarProfile> carProfiles = [];
  final List<RecordingMetadataData> metadataRows = [];
  int _nextCarProfileId = 1;
  int _nextMetadataId = 1;

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
  Future<void> renameRecording(int id, String newName) async {
    renamedRecordings.add((id: id, name: newName));
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

  @override
  Future<List<Recording>> getAllRecordings() async => [];

  @override
  Future<Recording> getRecording(int id) async =>
      throw StateError('No recording with id $id');

  @override
  Future<List<SensorSample>> getSamplesForRecording(int recordingId) async =>
      [];

  @override
  Future<List<CarProfile>> getAllCarProfiles() async =>
      List.unmodifiable(carProfiles);

  @override
  Future<CarProfile?> getCarProfile(int id) async {
    for (final cp in carProfiles) {
      if (cp.id == id) return cp;
    }
    return null;
  }

  @override
  Future<int> insertCarProfile(CarProfilesCompanion entry) async {
    final id = _nextCarProfileId++;
    carProfiles.add(
      CarProfile(
        id: id,
        name: entry.name.value,
        make: entry.make.present ? entry.make.value : '',
        model: entry.model.present ? entry.model.value : '',
        year: entry.year.present ? entry.year.value : null,
        fuelType: entry.fuelType.present ? entry.fuelType.value : '',
        transmission:
            entry.transmission.present ? entry.transmission.value : '',
      ),
    );
    return id;
  }

  @override
  Future<void> updateCarProfile(CarProfilesCompanion entry) async {
    final id = entry.id.value;
    for (var i = 0; i < carProfiles.length; i++) {
      if (carProfiles[i].id == id) {
        final cur = carProfiles[i];
        carProfiles[i] = CarProfile(
          id: cur.id,
          name: entry.name.present ? entry.name.value : cur.name,
          make: entry.make.present ? entry.make.value : cur.make,
          model: entry.model.present ? entry.model.value : cur.model,
          year: entry.year.present ? entry.year.value : cur.year,
          fuelType: entry.fuelType.present ? entry.fuelType.value : cur.fuelType,
          transmission: entry.transmission.present
              ? entry.transmission.value
              : cur.transmission,
        );
        return;
      }
    }
  }

  @override
  Future<void> deleteCarProfile(int id) async {
    carProfiles.removeWhere((cp) => cp.id == id);
    for (var i = 0; i < metadataRows.length; i++) {
      if (metadataRows[i].carProfileId == id) {
        final cur = metadataRows[i];
        metadataRows[i] = RecordingMetadataData(
          id: cur.id,
          recordingId: cur.recordingId,
          carProfileId: null,
          driveMode: cur.driveMode,
          passengerCount: cur.passengerCount,
          fuelLevelPercent: cur.fuelLevelPercent,
          tyreType: cur.tyreType,
          weatherNote: cur.weatherNote,
          freeText: cur.freeText,
        );
      }
    }
  }

  @override
  Future<RecordingMetadataData?> getMetadataForRecording(
    int recordingId,
  ) async {
    for (final m in metadataRows) {
      if (m.recordingId == recordingId) return m;
    }
    return null;
  }

  @override
  Future<int> upsertMetadata(RecordingMetadataCompanion entry) async {
    final recordingId = entry.recordingId.value;
    for (var i = 0; i < metadataRows.length; i++) {
      if (metadataRows[i].recordingId == recordingId) {
        final cur = metadataRows[i];
        metadataRows[i] = RecordingMetadataData(
          id: cur.id,
          recordingId: recordingId,
          carProfileId: entry.carProfileId.present
              ? entry.carProfileId.value
              : cur.carProfileId,
          driveMode:
              entry.driveMode.present ? entry.driveMode.value : cur.driveMode,
          passengerCount: entry.passengerCount.present
              ? entry.passengerCount.value
              : cur.passengerCount,
          fuelLevelPercent: entry.fuelLevelPercent.present
              ? entry.fuelLevelPercent.value
              : cur.fuelLevelPercent,
          tyreType:
              entry.tyreType.present ? entry.tyreType.value : cur.tyreType,
          weatherNote: entry.weatherNote.present
              ? entry.weatherNote.value
              : cur.weatherNote,
          freeText:
              entry.freeText.present ? entry.freeText.value : cur.freeText,
        );
        return cur.id;
      }
    }
    final id = _nextMetadataId++;
    metadataRows.add(
      RecordingMetadataData(
        id: id,
        recordingId: recordingId,
        carProfileId:
            entry.carProfileId.present ? entry.carProfileId.value : null,
        driveMode: entry.driveMode.present ? entry.driveMode.value : '',
        passengerCount:
            entry.passengerCount.present ? entry.passengerCount.value : null,
        fuelLevelPercent: entry.fuelLevelPercent.present
            ? entry.fuelLevelPercent.value
            : null,
        tyreType: entry.tyreType.present ? entry.tyreType.value : '',
        weatherNote:
            entry.weatherNote.present ? entry.weatherNote.value : '',
        freeText: entry.freeText.present ? entry.freeText.value : '',
      ),
    );
    return id;
  }
}

class FakeSensorService extends SensorService {
  final StreamController<AccelerometerReading> _accelController =
      StreamController<AccelerometerReading>.broadcast(sync: true);
  final StreamController<LinearAccelerometerReading> _linearAccelController =
      StreamController<LinearAccelerometerReading>.broadcast(sync: true);
  final StreamController<GyroscopeReading> _gyroController =
      StreamController<GyroscopeReading>.broadcast(sync: true);
  final StreamController<BarometerReading> _barometerController =
      StreamController<BarometerReading>.broadcast(sync: true);

  @override
  Stream<AccelerometerReading> get accelerometerStream =>
      _accelController.stream;

  @override
  Stream<LinearAccelerometerReading> get linearAccelerometerStream =>
      _linearAccelController.stream;

  @override
  Stream<GyroscopeReading> get gyroscopeStream => _gyroController.stream;

  @override
  Stream<BarometerReading> get barometerStream => _barometerController.stream;

  @override
  void startListening() {}

  @override
  void stopListening() {}

  @override
  void dispose() {
    _accelController.close();
    _linearAccelController.close();
    _gyroController.close();
    _barometerController.close();
  }

  void emitAccel(double x, double y, double z, DateTime timestamp) {
    _accelController.add(AccelerometerReading(x, y, z, timestamp));
  }

  void emitGyro(double x, double y, double z, DateTime timestamp) {
    _gyroController.add(GyroscopeReading(x, y, z, timestamp));
  }

  void emitLinearAccel(double x, double y, double z, DateTime timestamp) {
    _linearAccelController
        .add(LinearAccelerometerReading(x, y, z, timestamp));
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
    double latitude = 0,
    double longitude = 0,
  }) {
    _gpsController.add(
      GpsReading(
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        heading: heading,
        altitude: 0,
        accuracy: 1,
        timestamp: timestamp,
      ),
    );
  }
}

/// Creates a fake [Recording] for testing.
Recording fakeRecording({
  int id = 1,
  String name = 'Test Run',
  DateTime? startedAt,
  DateTime? endedAt,
  int durationMs = 30000,
  bool isDevRecording = false,
  String notes = '',
}) {
  final start = startedAt ?? DateTime(2025, 1, 15, 10, 30);
  return Recording(
    id: id,
    name: name,
    startedAt: start,
    endedAt: endedAt ?? start.add(Duration(milliseconds: durationMs)),
    durationMs: durationMs,
    isDevRecording: isDevRecording,
    notes: notes,
  );
}

/// Creates a fake [SensorSample] for testing.
SensorSample fakeSample({
  int id = 1,
  int recordingId = 1,
  int timestampUs = 0,
  double? accelX,
  double? accelY,
  double? accelZ,
  double? forwardAccel,
  double? lateralAccel,
  double? gpsSpeed,
  double? gpsLat,
  double? gpsLon,
  double? gpsHeading,
}) {
  return SensorSample(
    id: id,
    recordingId: recordingId,
    timestampUs: timestampUs,
    accelX: accelX,
    accelY: accelY,
    accelZ: accelZ,
    linearAccelX: null,
    linearAccelY: null,
    linearAccelZ: null,
    gyroX: null,
    gyroY: null,
    gyroZ: null,
    forwardAccel: forwardAccel,
    lateralAccel: lateralAccel,
    gpsSpeed: gpsSpeed,
    gpsLat: gpsLat,
    gpsLon: gpsLon,
    gpsHeading: gpsHeading,
    gpsAltitude: null,
    gpsAccuracy: null,
    gpsBearing: null,
    gravX: null,
    gravY: null,
    gravZ: null,
    pressure: null,
    quatW: null,
    quatX: null,
    quatY: null,
    quatZ: null,
  );
}

/// Fake database for widget tests that need a [RecordingStore] in the
/// provider tree. Supports both read and write operations.
class FakeDatabase extends FakeRecordingStore {
  List<Recording> _recordings = [];
  Map<int, List<SensorSample>> samplesByRecording = {};

  set recordings(List<Recording> value) => _recordings = value;

  @override
  Future<List<Recording>> getAllRecordings() async =>
      List.unmodifiable(_recordings);

  @override
  Future<Recording> getRecording(int id) async =>
      _recordings.firstWhere((r) => r.id == id);

  @override
  Future<void> deleteRecording(int id) async {
    await super.deleteRecording(id);
    _recordings.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> renameRecording(int id, String newName) async {
    await super.renameRecording(id, newName);
    _recordings = [
      for (final r in _recordings)
        if (r.id == id)
          Recording(
            id: r.id,
            name: newName,
            startedAt: r.startedAt,
            endedAt: r.endedAt,
            durationMs: r.durationMs,
            isDevRecording: r.isDevRecording,
            notes: r.notes,
          )
        else
          r,
    ];
  }

  @override
  Future<List<SensorSample>> getSamplesForRecording(int recordingId) async =>
      samplesByRecording[recordingId] ?? [];
}
