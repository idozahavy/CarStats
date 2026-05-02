import 'package:accel_stats/data/database/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Schema v4 → v5 migration', () {
    test('upgrade keeps existing data and creates the new tables', () async {
      // Build a schema-v4-shaped database manually inside an in-memory
      // sqlite, then re-open it through Drift so onUpgrade runs.
      final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
        raw.execute('''
          CREATE TABLE recordings (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            started_at INTEGER NOT NULL,
            ended_at INTEGER,
            duration_ms INTEGER NOT NULL DEFAULT 0,
            is_dev_recording INTEGER NOT NULL DEFAULT 0,
            notes TEXT NOT NULL DEFAULT ''
          );
        ''');
        raw.execute('''
          CREATE TABLE sensor_samples (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            recording_id INTEGER NOT NULL REFERENCES recordings (id),
            timestamp_us INTEGER NOT NULL,
            accel_x REAL,
            accel_y REAL,
            accel_z REAL,
            linear_accel_x REAL,
            linear_accel_y REAL,
            linear_accel_z REAL,
            gyro_x REAL,
            gyro_y REAL,
            gyro_z REAL,
            forward_accel REAL,
            lateral_accel REAL,
            gps_speed REAL,
            gps_lat REAL,
            gps_lon REAL,
            gps_heading REAL,
            gps_altitude REAL,
            gps_accuracy REAL,
            gps_bearing REAL,
            grav_x REAL,
            grav_y REAL,
            grav_z REAL,
            pressure REAL,
            quat_w REAL,
            quat_x REAL,
            quat_y REAL,
            quat_z REAL
          );
        ''');
        raw.execute('PRAGMA user_version = 4;');
        raw.execute(
          "INSERT INTO recordings (name, started_at, duration_ms) "
          "VALUES ('Old run', 1735000000000, 5000);",
        );
      }));

      // Touch the database — this triggers Drift's onUpgrade.
      final recordings = await db.getAllRecordings();
      expect(recordings, hasLength(1));
      expect(recordings.single.name, 'Old run');
      expect(recordings.single.durationMs, 5000);

      // The new tables exist and are queryable.
      final cars = await db.getAllCarProfiles();
      expect(cars, isEmpty);
      final metadata =
          await db.getMetadataForRecording(recordings.single.id);
      expect(metadata, isNull);

      // CRUD round-trip on the new tables works.
      final carId = await db.insertCarProfile(
        CarProfilesCompanion.insert(name: 'Test car'),
      );
      await db.upsertMetadata(
        RecordingMetadataCompanion.insert(
          recordingId: recordings.single.id,
          carProfileId: Value(carId),
          driveMode: const Value('sport'),
        ),
      );
      final after = await db.getMetadataForRecording(recordings.single.id);
      expect(after, isNotNull);
      expect(after!.carProfileId, carId);
      expect(after.driveMode, 'sport');

      await db.close();
    });

    test('upsertMetadata updates existing row instead of inserting', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final recId = await db.insertRecording(
        RecordingsCompanion.insert(
          name: 'Run',
          startedAt: DateTime.utc(2026, 5, 1),
        ),
      );

      final firstId = await db.upsertMetadata(
        RecordingMetadataCompanion.insert(
          recordingId: recId,
          driveMode: const Value('eco'),
        ),
      );
      final secondId = await db.upsertMetadata(
        RecordingMetadataCompanion.insert(
          recordingId: recId,
          driveMode: const Value('sport'),
        ),
      );

      expect(firstId, secondId);
      final m = await db.getMetadataForRecording(recId);
      expect(m!.driveMode, 'sport');

      await db.close();
    });
  });
}
