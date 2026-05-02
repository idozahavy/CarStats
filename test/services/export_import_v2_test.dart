import 'dart:convert';

import 'package:accel_stats/data/database/database.dart';
import 'package:accel_stats/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('ExportService v2 metadata round-trip', () {
    test('exports and re-imports car profile + metadata', () async {
      final recording = fakeRecording(
        id: 7,
        name: 'Track day',
        startedAt: DateTime.utc(2026, 5, 1, 9),
        durationMs: 60000,
      );
      final samples = [fakeSample(id: 1, recordingId: 7, timestampUs: 0)];
      final carProfile = CarProfile(
        id: 3,
        name: 'My GT3',
        make: 'Porsche',
        model: '911 GT3',
        year: 2024,
        fuelType: 'petrol',
        transmission: 'dct',
      );
      final metadata = RecordingMetadataData(
        id: 1,
        recordingId: 7,
        carProfileId: 3,
        driveMode: 'sport',
        passengerCount: 1,
        fuelLevelPercent: 80,
        tyreType: 'Cup 2',
        weatherNote: 'dry, 22C',
        freeText: 'Lap 4 was the fast one.',
      );

      final json = ExportService.toJsonString(
        recording,
        samples,
        metadata: metadata,
        carProfile: carProfile,
      );
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['exportVersion'], 2);
      expect(decoded['carProfile'], isA<Map<String, dynamic>>());
      expect(decoded['metadata'], isA<Map<String, dynamic>>());

      final store = FakeRecordingStore();
      final newId = await ExportService.importRecordingFromJson(store, json);
      expect(newId, isPositive);

      expect(store.carProfiles, hasLength(1));
      final importedCar = store.carProfiles.single;
      expect(importedCar.name, 'My GT3');
      expect(importedCar.make, 'Porsche');
      expect(importedCar.model, '911 GT3');
      expect(importedCar.year, 2024);
      expect(importedCar.fuelType, 'petrol');
      expect(importedCar.transmission, 'dct');

      expect(store.metadataRows, hasLength(1));
      final importedMeta = store.metadataRows.single;
      expect(importedMeta.recordingId, newId);
      expect(importedMeta.carProfileId, importedCar.id);
      expect(importedMeta.driveMode, 'sport');
      expect(importedMeta.passengerCount, 1);
      expect(importedMeta.fuelLevelPercent, 80);
      expect(importedMeta.tyreType, 'Cup 2');
      expect(importedMeta.weatherNote, 'dry, 22C');
      expect(importedMeta.freeText, 'Lap 4 was the fast one.');
    });

    test('v2 export with null metadata round-trips empty', () async {
      final recording = fakeRecording(id: 8, name: 'Plain run');
      final json = ExportService.toJsonString(
        recording,
        const [],
      );
      final store = FakeRecordingStore();
      await ExportService.importRecordingFromJson(store, json);
      expect(store.carProfiles, isEmpty);
      expect(store.metadataRows, isEmpty);
    });

  });
}
