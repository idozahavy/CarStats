import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import '../data/database/database.dart';

enum ExportFormat { csv, json }

class ExportService {
  static const int exportVersion = 1;

  static Future<File?> exportRecording(
    Recording recording,
    List<SensorSample> samples,
    ExportFormat format,
  ) async {
    final safeName = recording.name.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    final ext = format == ExportFormat.csv ? 'csv' : 'json';
    final defaultName = '${safeName}_${recording.id}.$ext';

    final content = switch (format) {
      ExportFormat.csv => _toCsv(recording, samples),
      ExportFormat.json => _toJson(recording, samples),
    };

    final bytes = utf8.encode(content);

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Recording',
      fileName: defaultName,
      type: FileType.custom,
      allowedExtensions: [ext],
      bytes: Uint8List.fromList(bytes),
    );
    if (savePath == null) return null;

    // On desktop, FilePicker doesn't write bytes — write manually.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final file = File(savePath);
      await file.writeAsString(content);
      return file;
    }

    return File(savePath);
  }

  static Future<int?> importRecording(RecordingStore db) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Recording',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;

    final filePath = result.files.single.path;
    if (filePath == null) return null;

    final content = await File(filePath).readAsString();
    return importRecordingFromJson(db, content);
  }

  /// Parses [jsonContent] and inserts a new recording + samples into [db].
  /// Throws [FormatException] for missing/wrong version or malformed shape.
  static Future<int> importRecordingFromJson(
    RecordingStore db,
    String jsonContent,
  ) async {
    final data = jsonDecode(jsonContent) as Map<String, dynamic>;

    final foundVersion = data['exportVersion'];
    if (foundVersion != exportVersion) {
      throw FormatException(
        'Unsupported export version: $foundVersion. Expected: $exportVersion.',
      );
    }

    if (data['recording'] is! Map<String, dynamic> ||
        data['samples'] is! List<dynamic>) {
      throw const FormatException(
        "Malformed export: missing 'recording' or 'samples'",
      );
    }

    final rec = data['recording'] as Map<String, dynamic>;
    final samples = data['samples'] as List<dynamic>;

    final recordingId = await db.insertRecording(
      RecordingsCompanion.insert(
        name: rec['name'] as String,
        startedAt: DateTime.parse(rec['startedAt'] as String),
        endedAt: rec['endedAt'] != null
            ? Value(DateTime.parse(rec['endedAt'] as String))
            : const Value.absent(),
        durationMs: Value(rec['durationMs'] as int? ?? 0),
        notes: Value(rec['notes'] as String? ?? ''),
      ),
    );

    final batch = samples
        .cast<Map<String, dynamic>>()
        .map(
          (s) => SensorSamplesCompanion.insert(
            recordingId: recordingId,
            timestampUs: s['timestampUs'] as int,
            accelX: Value(s['accelX'] as double?),
            accelY: Value(s['accelY'] as double?),
            accelZ: Value(s['accelZ'] as double?),
            linearAccelX: Value(s['linearAccelX'] as double?),
            linearAccelY: Value(s['linearAccelY'] as double?),
            linearAccelZ: Value(s['linearAccelZ'] as double?),
            gyroX: Value(s['gyroX'] as double?),
            gyroY: Value(s['gyroY'] as double?),
            gyroZ: Value(s['gyroZ'] as double?),
            forwardAccel: Value(s['forwardAccel'] as double?),
            lateralAccel: Value(s['lateralAccel'] as double?),
            gpsSpeed: Value(s['gpsSpeed'] as double?),
            gpsLat: Value(s['gpsLat'] as double?),
            gpsLon: Value(s['gpsLon'] as double?),
            gpsHeading: Value(s['gpsHeading'] as double?),
            gpsAltitude: Value(s['gpsAltitude'] as double?),
            gpsAccuracy: Value(s['gpsAccuracy'] as double?),
            gpsBearing: Value(s['gpsBearing'] as double?),
            gravX: Value(s['gravX'] as double?),
            gravY: Value(s['gravY'] as double?),
            gravZ: Value(s['gravZ'] as double?),
            pressure: Value(s['pressure'] as double?),
            quatW: Value(s['quatW'] as double?),
            quatX: Value(s['quatX'] as double?),
            quatY: Value(s['quatY'] as double?),
            quatZ: Value(s['quatZ'] as double?),
          ),
        )
        .toList();

    await db.insertSensorSamplesBatch(batch);
    return recordingId;
  }

  @visibleForTesting
  static String toJsonString(Recording recording, List<SensorSample> samples) =>
      _toJson(recording, samples);

  static String _toCsv(Recording recording, List<SensorSample> samples) {
    final buf = StringBuffer();

    buf.writeln(
      'timestampUs,accelX,accelY,accelZ,'
      'linearAccelX,linearAccelY,linearAccelZ,'
      'gyroX,gyroY,gyroZ,'
      'forwardAccel,lateralAccel,'
      'gpsSpeed,gpsLat,gpsLon,gpsHeading,gpsAltitude,gpsAccuracy,gpsBearing,'
      'gravX,gravY,gravZ,'
      'pressure,'
      'quatW,quatX,quatY,quatZ',
    );

    for (final s in samples) {
      buf.writeln(
        '${s.timestampUs},'
        '${s.accelX ?? ''},${s.accelY ?? ''},${s.accelZ ?? ''},'
        '${s.linearAccelX ?? ''},${s.linearAccelY ?? ''},${s.linearAccelZ ?? ''},'
        '${s.gyroX ?? ''},${s.gyroY ?? ''},${s.gyroZ ?? ''},'
        '${s.forwardAccel ?? ''},${s.lateralAccel ?? ''},'
        '${s.gpsSpeed ?? ''},${s.gpsLat ?? ''},${s.gpsLon ?? ''},'
        '${s.gpsHeading ?? ''},${s.gpsAltitude ?? ''},${s.gpsAccuracy ?? ''},${s.gpsBearing ?? ''},'
        '${s.gravX ?? ''},${s.gravY ?? ''},${s.gravZ ?? ''},'
        '${s.pressure ?? ''},'
        '${s.quatW ?? ''},${s.quatX ?? ''},${s.quatY ?? ''},${s.quatZ ?? ''}',
      );
    }

    return buf.toString();
  }

  static String _toJson(Recording recording, List<SensorSample> samples) {
    final data = {
      'exportVersion': exportVersion,
      'recording': {
        'id': recording.id,
        'name': recording.name,
        'startedAt': recording.startedAt.toIso8601String(),
        'endedAt': recording.endedAt?.toIso8601String(),
        'durationMs': recording.durationMs,
        'notes': recording.notes,
      },
      'samples': samples
          .map(
            (s) => {
              'timestampUs': s.timestampUs,
              'accelX': s.accelX,
              'accelY': s.accelY,
              'accelZ': s.accelZ,
              'linearAccelX': s.linearAccelX,
              'linearAccelY': s.linearAccelY,
              'linearAccelZ': s.linearAccelZ,
              'gyroX': s.gyroX,
              'gyroY': s.gyroY,
              'gyroZ': s.gyroZ,
              'forwardAccel': s.forwardAccel,
              'lateralAccel': s.lateralAccel,
              'gpsSpeed': s.gpsSpeed,
              'gpsLat': s.gpsLat,
              'gpsLon': s.gpsLon,
              'gpsHeading': s.gpsHeading,
              'gpsAltitude': s.gpsAltitude,
              'gpsAccuracy': s.gpsAccuracy,
              'gpsBearing': s.gpsBearing,
              'gravX': s.gravX,
              'gravY': s.gravY,
              'gravZ': s.gravZ,
              'pressure': s.pressure,
              'quatW': s.quatW,
              'quatX': s.quatX,
              'quatY': s.quatY,
              'quatZ': s.quatZ,
            },
          )
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
