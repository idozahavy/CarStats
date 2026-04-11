import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Recordings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  BoolColumn get isDevRecording => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

class SensorSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recordingId => integer().references(Recordings, #id)();
  IntColumn get timestampUs => integer()(); // microseconds since recording start

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

  // Calculated forward acceleration
  RealColumn get forwardAccel => real().nullable()();

  // GPS data
  RealColumn get gpsSpeed => real().nullable()(); // m/s
  RealColumn get gpsLat => real().nullable()();
  RealColumn get gpsLon => real().nullable()();
  RealColumn get gpsHeading => real().nullable()();
  RealColumn get gpsAltitude => real().nullable()();
  RealColumn get gpsAccuracy => real().nullable()();
}

@DriftDatabase(tables: [Recordings, SensorSamples])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  static AppDatabase? _instance;

  factory AppDatabase() {
    _instance ??= AppDatabase._internal(_openConnection());
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  // --- Recording queries ---

  Future<List<Recording>> getAllRecordings() {
    return (select(recordings)..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get();
  }

  Future<Recording> getRecording(int id) {
    return (select(recordings)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> insertRecording(RecordingsCompanion entry) {
    return into(recordings).insert(entry);
  }

  Future<void> updateRecording(RecordingsCompanion entry) {
    return (update(recordings)..where((t) => t.id.equals(entry.id.value))).write(entry);
  }

  Future<void> deleteRecording(int id) {
    return transaction(() async {
      await (delete(sensorSamples)..where((t) => t.recordingId.equals(id))).go();
      await (delete(recordings)..where((t) => t.id.equals(id))).go();
    });
  }

  // --- Sensor sample queries ---

  Future<void> insertSensorSamplesBatch(List<SensorSamplesCompanion> entries) {
    return batch((b) => b.insertAll(sensorSamples, entries));
  }

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'car_stats.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
