import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

abstract interface class RecordingStore {
  Future<int> insertRecording(RecordingsCompanion entry);
  Future<void> updateRecording(RecordingsCompanion entry);
  Future<void> renameRecording(int id, String newName);
  Future<void> deleteRecording(int id);
  Future<void> insertSensorSamplesBatch(List<SensorSamplesCompanion> entries);
  Future<List<Recording>> getAllRecordings();
  Future<Recording> getRecording(int id);
  Future<List<SensorSample>> getSamplesForRecording(int recordingId);

  // Car profiles
  Future<List<CarProfile>> getAllCarProfiles();
  Future<CarProfile?> getCarProfile(int id);
  Future<int> insertCarProfile(CarProfilesCompanion entry);
  Future<void> updateCarProfile(CarProfilesCompanion entry);
  Future<void> deleteCarProfile(int id);

  // Recording metadata
  Future<RecordingMetadataData?> getMetadataForRecording(int recordingId);
  Future<int> upsertMetadata(RecordingMetadataCompanion entry);
}

class Recordings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  BoolColumn get isDevRecording =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

class SensorSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recordingId => integer().references(Recordings, #id)();
  IntColumn get timestampUs =>
      integer()(); // microseconds since recording start

  // Raw accelerometer
  RealColumn get accelX => real().nullable()();
  RealColumn get accelY => real().nullable()();
  RealColumn get accelZ => real().nullable()();

  // Linear acceleration (platform sensor fusion)
  RealColumn get linearAccelX => real().nullable()();
  RealColumn get linearAccelY => real().nullable()();
  RealColumn get linearAccelZ => real().nullable()();

  // Gyroscope
  RealColumn get gyroX => real().nullable()();
  RealColumn get gyroY => real().nullable()();
  RealColumn get gyroZ => real().nullable()();

  // Calculated forward/lateral acceleration
  RealColumn get forwardAccel => real().nullable()();
  RealColumn get lateralAccel => real().nullable()();

  // GPS data
  RealColumn get gpsSpeed => real().nullable()(); // m/s
  RealColumn get gpsLat => real().nullable()();
  RealColumn get gpsLon => real().nullable()();
  RealColumn get gpsHeading => real().nullable()();
  RealColumn get gpsAltitude => real().nullable()();
  RealColumn get gpsAccuracy => real().nullable()();
  RealColumn get gpsBearing => real().nullable()(); // derived bearing (degrees)

  // Gravity vector (world-frame Z axis in phone coords)
  RealColumn get gravX => real().nullable()();
  RealColumn get gravY => real().nullable()();
  RealColumn get gravZ => real().nullable()();

  // Barometric pressure (hPa)
  RealColumn get pressure => real().nullable()();

  // Phone orientation quaternion (world-from-phone rotation)
  RealColumn get quatW => real().nullable()();
  RealColumn get quatX => real().nullable()();
  RealColumn get quatY => real().nullable()();
  RealColumn get quatZ => real().nullable()();
}

class CarProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get make => text().withDefault(const Constant(''))();
  TextColumn get model => text().withDefault(const Constant(''))();
  IntColumn get year => integer().nullable()();
  TextColumn get fuelType => text().withDefault(const Constant(''))();
  TextColumn get transmission => text().withDefault(const Constant(''))();
}

class RecordingMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recordingId => integer().references(Recordings, #id)();
  IntColumn get carProfileId =>
      integer().nullable().references(CarProfiles, #id)();
  TextColumn get driveMode => text().withDefault(const Constant(''))();
  IntColumn get passengerCount => integer().nullable()();
  IntColumn get fuelLevelPercent => integer().nullable()();
  TextColumn get tyreType => text().withDefault(const Constant(''))();
  TextColumn get weatherNote => text().withDefault(const Constant(''))();
  TextColumn get freeText => text().withDefault(const Constant(''))();
}

@DriftDatabase(tables: [Recordings, SensorSamples, CarProfiles, RecordingMetadata])
class AppDatabase extends _$AppDatabase implements RecordingStore {
  AppDatabase._internal(super.e);

  @visibleForTesting
  AppDatabase.forTesting(super.e);

  static AppDatabase? _instance;

  factory AppDatabase() {
    _instance ??= AppDatabase._internal(_openConnection());
    return _instance!;
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN gps_bearing REAL',
        );
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN grav_x REAL',
        );
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN grav_y REAL',
        );
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN grav_z REAL',
        );
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN pressure REAL',
        );
      }
      if (from < 3) {
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN quat_w REAL',
        );
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN quat_x REAL',
        );
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN quat_y REAL',
        );
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN quat_z REAL',
        );
      }
      if (from < 4) {
        await customStatement(
          'ALTER TABLE sensor_samples ADD COLUMN lateral_accel REAL',
        );
      }
      if (from < 5) {
        await migrator.createTable(carProfiles);
        await migrator.createTable(recordingMetadata);
      }
    },
  );

  // --- Recording queries ---

  @override
  Future<List<Recording>> getAllRecordings() {
    return (select(
      recordings,
    )..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();
  }

  @override
  Future<Recording> getRecording(int id) {
    return (select(recordings)..where((t) => t.id.equals(id))).getSingle();
  }

  @override
  Future<int> insertRecording(RecordingsCompanion entry) {
    return into(recordings).insert(entry);
  }

  @override
  Future<void> updateRecording(RecordingsCompanion entry) {
    return (update(
      recordings,
    )..where((t) => t.id.equals(entry.id.value))).write(entry);
  }

  @override
  Future<void> renameRecording(int id, String newName) {
    return (update(recordings)..where((t) => t.id.equals(id)))
        .write(RecordingsCompanion(name: Value(newName)));
  }

  @override
  Future<void> deleteRecording(int id) {
    return transaction(() async {
      await (delete(
        recordingMetadata,
      )..where((t) => t.recordingId.equals(id))).go();
      await (delete(
        sensorSamples,
      )..where((t) => t.recordingId.equals(id))).go();
      await (delete(recordings)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Sensor sample queries ---

  @override
  Future<void> insertSensorSamplesBatch(List<SensorSamplesCompanion> entries) {
    return batch((b) => b.insertAll(sensorSamples, entries));
  }

  @override
  Future<List<SensorSample>> getSamplesForRecording(int recordingId) {
    return (select(sensorSamples)
          ..where((t) => t.recordingId.equals(recordingId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestampUs)]))
        .get();
  }

  Stream<List<SensorSample>> watchSamplesForRecording(int recordingId) {
    return (select(sensorSamples)
          ..where((t) => t.recordingId.equals(recordingId))
          ..orderBy([(t) => OrderingTerm.asc(t.timestampUs)]))
        .watch();
  }

  // --- Car profile queries ---

  @override
  Future<List<CarProfile>> getAllCarProfiles() {
    return (select(carProfiles)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  @override
  Future<CarProfile?> getCarProfile(int id) {
    return (select(carProfiles)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insertCarProfile(CarProfilesCompanion entry) {
    return into(carProfiles).insert(entry);
  }

  @override
  Future<void> updateCarProfile(CarProfilesCompanion entry) {
    return (update(carProfiles)
          ..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  @override
  Future<void> deleteCarProfile(int id) {
    return transaction(() async {
      await (update(recordingMetadata)
            ..where((t) => t.carProfileId.equals(id)))
          .write(const RecordingMetadataCompanion(
            carProfileId: Value(null),
          ));
      await (delete(carProfiles)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Recording metadata queries ---

  @override
  Future<RecordingMetadataData?> getMetadataForRecording(int recordingId) {
    return (select(recordingMetadata)
          ..where((t) => t.recordingId.equals(recordingId)))
        .getSingleOrNull();
  }

  @override
  Future<int> upsertMetadata(RecordingMetadataCompanion entry) async {
    final recordingId = entry.recordingId.value;
    final existing = await getMetadataForRecording(recordingId);
    if (existing == null) {
      return into(recordingMetadata).insert(entry);
    }
    await (update(recordingMetadata)
          ..where((t) => t.id.equals(existing.id)))
        .write(entry);
    return existing.id;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'accel_stats.sqlite'));

    // Migrate old database file name if it exists.
    if (!file.existsSync()) {
      final oldFile = File(p.join(dbFolder.path, 'car_stats.sqlite'));
      if (oldFile.existsSync()) {
        oldFile.renameSync(file.path);
      }
    }

    return NativeDatabase.createInBackground(file);
  });
}
