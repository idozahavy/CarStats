import 'dart:convert';

import 'package:accel_stats/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('ExportService import validation', () {
    test('round-trip preserves recording and sample fields', () async {
      final recording = fakeRecording(
        id: 42,
        name: 'Loop A',
        startedAt: DateTime.utc(2026, 1, 15, 10, 30),
        durationMs: 12345,
        notes: 'first run',
      );
      final samples = [
        fakeSample(
          id: 1,
          recordingId: 42,
          timestampUs: 0,
          accelX: 0.1,
          accelY: 0.2,
          accelZ: 9.81,
          forwardAccel: 1.5,
          lateralAccel: -0.3,
          gpsSpeed: 5.0,
          gpsLat: 32.1,
          gpsLon: 34.8,
          gpsHeading: 90.0,
        ),
        fakeSample(
          id: 2,
          recordingId: 42,
          timestampUs: 20000,
          accelX: 0.2,
          accelY: 0.1,
          accelZ: 9.80,
          forwardAccel: 1.7,
          lateralAccel: -0.1,
          gpsSpeed: 5.5,
          gpsLat: 32.1001,
          gpsLon: 34.8001,
          gpsHeading: 91.0,
        ),
      ];

      final json = ExportService.toJsonString(recording, samples);
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['exportVersion'], ExportService.exportVersion);

      final store = FakeRecordingStore();
      final newId = await ExportService.importRecordingFromJson(store, json);

      expect(newId, isPositive);
      expect(store.insertedRecordings, hasLength(1));
      final inserted = store.insertedRecordings.single;
      expect(inserted.name.value, 'Loop A');
      expect(inserted.startedAt.value, recording.startedAt);
      expect(inserted.endedAt.value, recording.endedAt);
      expect(inserted.durationMs.value, 12345);
      expect(inserted.notes.value, 'first run');

      expect(store.insertedSamples, hasLength(2));
      expect(store.insertedSamples[0].timestampUs.value, 0);
      expect(store.insertedSamples[0].accelX.value, 0.1);
      expect(store.insertedSamples[0].forwardAccel.value, 1.5);
      expect(store.insertedSamples[0].gpsHeading.value, 90.0);
      expect(store.insertedSamples[1].timestampUs.value, 20000);
      expect(store.insertedSamples[1].gpsSpeed.value, 5.5);
    });

    test('rejects JSON without an exportVersion field', () async {
      final json = jsonEncode({
        'recording': {
          'name': 'x',
          'startedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
        'samples': <Map<String, dynamic>>[],
      });
      final store = FakeRecordingStore();

      expect(
        () => ExportService.importRecordingFromJson(store, json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects JSON with an unsupported exportVersion', () async {
      final json = jsonEncode({
        'exportVersion': 999,
        'recording': {
          'name': 'x',
          'startedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
        'samples': <Map<String, dynamic>>[],
      });
      final store = FakeRecordingStore();

      expect(
        () => ExportService.importRecordingFromJson(store, json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects JSON missing the samples key', () async {
      final json = jsonEncode({
        'exportVersion': ExportService.exportVersion,
        'recording': {
          'name': 'x',
          'startedAt': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
      });
      final store = FakeRecordingStore();

      expect(
        () => ExportService.importRecordingFromJson(store, json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
