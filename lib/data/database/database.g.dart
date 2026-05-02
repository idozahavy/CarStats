// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RecordingsTable extends Recordings
    with TableInfo<$RecordingsTable, Recording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isDevRecordingMeta = const VerificationMeta(
    'isDevRecording',
  );
  @override
  late final GeneratedColumn<bool> isDevRecording = GeneratedColumn<bool>(
    'is_dev_recording',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dev_recording" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startedAt,
    endedAt,
    durationMs,
    isDevRecording,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('is_dev_recording')) {
      context.handle(
        _isDevRecordingMeta,
        isDevRecording.isAcceptableOrUnknown(
          data['is_dev_recording']!,
          _isDevRecordingMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      isDevRecording: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dev_recording'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $RecordingsTable createAlias(String alias) {
    return $RecordingsTable(attachedDatabase, alias);
  }
}

class Recording extends DataClass implements Insertable<Recording> {
  final int id;
  final String name;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMs;
  final bool isDevRecording;
  final String notes;
  const Recording({
    required this.id,
    required this.name,
    required this.startedAt,
    this.endedAt,
    required this.durationMs,
    required this.isDevRecording,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['is_dev_recording'] = Variable<bool>(isDevRecording);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  RecordingsCompanion toCompanion(bool nullToAbsent) {
    return RecordingsCompanion(
      id: Value(id),
      name: Value(name),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMs: Value(durationMs),
      isDevRecording: Value(isDevRecording),
      notes: Value(notes),
    );
  }

  factory Recording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recording(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      isDevRecording: serializer.fromJson<bool>(json['isDevRecording']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'isDevRecording': serializer.toJson<bool>(isDevRecording),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Recording copyWith({
    int? id,
    String? name,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationMs,
    bool? isDevRecording,
    String? notes,
  }) => Recording(
    id: id ?? this.id,
    name: name ?? this.name,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMs: durationMs ?? this.durationMs,
    isDevRecording: isDevRecording ?? this.isDevRecording,
    notes: notes ?? this.notes,
  );
  Recording copyWithCompanion(RecordingsCompanion data) {
    return Recording(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      isDevRecording: data.isDevRecording.present
          ? data.isDevRecording.value
          : this.isDevRecording,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recording(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('isDevRecording: $isDevRecording, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startedAt,
    endedAt,
    durationMs,
    isDevRecording,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recording &&
          other.id == this.id &&
          other.name == this.name &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs &&
          other.isDevRecording == this.isDevRecording &&
          other.notes == this.notes);
}

class RecordingsCompanion extends UpdateCompanion<Recording> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationMs;
  final Value<bool> isDevRecording;
  final Value<String> notes;
  const RecordingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isDevRecording = const Value.absent(),
    this.notes = const Value.absent(),
  });
  RecordingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.isDevRecording = const Value.absent(),
    this.notes = const Value.absent(),
  }) : name = Value(name),
       startedAt = Value(startedAt);
  static Insertable<Recording> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMs,
    Expression<bool>? isDevRecording,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (isDevRecording != null) 'is_dev_recording': isDevRecording,
      if (notes != null) 'notes': notes,
    });
  }

  RecordingsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationMs,
    Value<bool>? isDevRecording,
    Value<String>? notes,
  }) {
    return RecordingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      isDevRecording: isDevRecording ?? this.isDevRecording,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (isDevRecording.present) {
      map['is_dev_recording'] = Variable<bool>(isDevRecording.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('isDevRecording: $isDevRecording, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SensorSamplesTable extends SensorSamples
    with TableInfo<$SensorSamplesTable, SensorSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<int> recordingId = GeneratedColumn<int>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recordings (id)',
    ),
  );
  static const VerificationMeta _timestampUsMeta = const VerificationMeta(
    'timestampUs',
  );
  @override
  late final GeneratedColumn<int> timestampUs = GeneratedColumn<int>(
    'timestamp_us',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelXMeta = const VerificationMeta('accelX');
  @override
  late final GeneratedColumn<double> accelX = GeneratedColumn<double>(
    'accel_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelYMeta = const VerificationMeta('accelY');
  @override
  late final GeneratedColumn<double> accelY = GeneratedColumn<double>(
    'accel_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelZMeta = const VerificationMeta('accelZ');
  @override
  late final GeneratedColumn<double> accelZ = GeneratedColumn<double>(
    'accel_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linearAccelXMeta = const VerificationMeta(
    'linearAccelX',
  );
  @override
  late final GeneratedColumn<double> linearAccelX = GeneratedColumn<double>(
    'linear_accel_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linearAccelYMeta = const VerificationMeta(
    'linearAccelY',
  );
  @override
  late final GeneratedColumn<double> linearAccelY = GeneratedColumn<double>(
    'linear_accel_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linearAccelZMeta = const VerificationMeta(
    'linearAccelZ',
  );
  @override
  late final GeneratedColumn<double> linearAccelZ = GeneratedColumn<double>(
    'linear_accel_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroXMeta = const VerificationMeta('gyroX');
  @override
  late final GeneratedColumn<double> gyroX = GeneratedColumn<double>(
    'gyro_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroYMeta = const VerificationMeta('gyroY');
  @override
  late final GeneratedColumn<double> gyroY = GeneratedColumn<double>(
    'gyro_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroZMeta = const VerificationMeta('gyroZ');
  @override
  late final GeneratedColumn<double> gyroZ = GeneratedColumn<double>(
    'gyro_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forwardAccelMeta = const VerificationMeta(
    'forwardAccel',
  );
  @override
  late final GeneratedColumn<double> forwardAccel = GeneratedColumn<double>(
    'forward_accel',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lateralAccelMeta = const VerificationMeta(
    'lateralAccel',
  );
  @override
  late final GeneratedColumn<double> lateralAccel = GeneratedColumn<double>(
    'lateral_accel',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsSpeedMeta = const VerificationMeta(
    'gpsSpeed',
  );
  @override
  late final GeneratedColumn<double> gpsSpeed = GeneratedColumn<double>(
    'gps_speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsLatMeta = const VerificationMeta('gpsLat');
  @override
  late final GeneratedColumn<double> gpsLat = GeneratedColumn<double>(
    'gps_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsLonMeta = const VerificationMeta('gpsLon');
  @override
  late final GeneratedColumn<double> gpsLon = GeneratedColumn<double>(
    'gps_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsHeadingMeta = const VerificationMeta(
    'gpsHeading',
  );
  @override
  late final GeneratedColumn<double> gpsHeading = GeneratedColumn<double>(
    'gps_heading',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAltitudeMeta = const VerificationMeta(
    'gpsAltitude',
  );
  @override
  late final GeneratedColumn<double> gpsAltitude = GeneratedColumn<double>(
    'gps_altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsAccuracyMeta = const VerificationMeta(
    'gpsAccuracy',
  );
  @override
  late final GeneratedColumn<double> gpsAccuracy = GeneratedColumn<double>(
    'gps_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsBearingMeta = const VerificationMeta(
    'gpsBearing',
  );
  @override
  late final GeneratedColumn<double> gpsBearing = GeneratedColumn<double>(
    'gps_bearing',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gravXMeta = const VerificationMeta('gravX');
  @override
  late final GeneratedColumn<double> gravX = GeneratedColumn<double>(
    'grav_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gravYMeta = const VerificationMeta('gravY');
  @override
  late final GeneratedColumn<double> gravY = GeneratedColumn<double>(
    'grav_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gravZMeta = const VerificationMeta('gravZ');
  @override
  late final GeneratedColumn<double> gravZ = GeneratedColumn<double>(
    'grav_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pressureMeta = const VerificationMeta(
    'pressure',
  );
  @override
  late final GeneratedColumn<double> pressure = GeneratedColumn<double>(
    'pressure',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatWMeta = const VerificationMeta('quatW');
  @override
  late final GeneratedColumn<double> quatW = GeneratedColumn<double>(
    'quat_w',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatXMeta = const VerificationMeta('quatX');
  @override
  late final GeneratedColumn<double> quatX = GeneratedColumn<double>(
    'quat_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatYMeta = const VerificationMeta('quatY');
  @override
  late final GeneratedColumn<double> quatY = GeneratedColumn<double>(
    'quat_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quatZMeta = const VerificationMeta('quatZ');
  @override
  late final GeneratedColumn<double> quatZ = GeneratedColumn<double>(
    'quat_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    timestampUs,
    accelX,
    accelY,
    accelZ,
    linearAccelX,
    linearAccelY,
    linearAccelZ,
    gyroX,
    gyroY,
    gyroZ,
    forwardAccel,
    lateralAccel,
    gpsSpeed,
    gpsLat,
    gpsLon,
    gpsHeading,
    gpsAltitude,
    gpsAccuracy,
    gpsBearing,
    gravX,
    gravY,
    gravZ,
    pressure,
    quatW,
    quatX,
    quatY,
    quatZ,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('timestamp_us')) {
      context.handle(
        _timestampUsMeta,
        timestampUs.isAcceptableOrUnknown(
          data['timestamp_us']!,
          _timestampUsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUsMeta);
    }
    if (data.containsKey('accel_x')) {
      context.handle(
        _accelXMeta,
        accelX.isAcceptableOrUnknown(data['accel_x']!, _accelXMeta),
      );
    }
    if (data.containsKey('accel_y')) {
      context.handle(
        _accelYMeta,
        accelY.isAcceptableOrUnknown(data['accel_y']!, _accelYMeta),
      );
    }
    if (data.containsKey('accel_z')) {
      context.handle(
        _accelZMeta,
        accelZ.isAcceptableOrUnknown(data['accel_z']!, _accelZMeta),
      );
    }
    if (data.containsKey('linear_accel_x')) {
      context.handle(
        _linearAccelXMeta,
        linearAccelX.isAcceptableOrUnknown(
          data['linear_accel_x']!,
          _linearAccelXMeta,
        ),
      );
    }
    if (data.containsKey('linear_accel_y')) {
      context.handle(
        _linearAccelYMeta,
        linearAccelY.isAcceptableOrUnknown(
          data['linear_accel_y']!,
          _linearAccelYMeta,
        ),
      );
    }
    if (data.containsKey('linear_accel_z')) {
      context.handle(
        _linearAccelZMeta,
        linearAccelZ.isAcceptableOrUnknown(
          data['linear_accel_z']!,
          _linearAccelZMeta,
        ),
      );
    }
    if (data.containsKey('gyro_x')) {
      context.handle(
        _gyroXMeta,
        gyroX.isAcceptableOrUnknown(data['gyro_x']!, _gyroXMeta),
      );
    }
    if (data.containsKey('gyro_y')) {
      context.handle(
        _gyroYMeta,
        gyroY.isAcceptableOrUnknown(data['gyro_y']!, _gyroYMeta),
      );
    }
    if (data.containsKey('gyro_z')) {
      context.handle(
        _gyroZMeta,
        gyroZ.isAcceptableOrUnknown(data['gyro_z']!, _gyroZMeta),
      );
    }
    if (data.containsKey('forward_accel')) {
      context.handle(
        _forwardAccelMeta,
        forwardAccel.isAcceptableOrUnknown(
          data['forward_accel']!,
          _forwardAccelMeta,
        ),
      );
    }
    if (data.containsKey('lateral_accel')) {
      context.handle(
        _lateralAccelMeta,
        lateralAccel.isAcceptableOrUnknown(
          data['lateral_accel']!,
          _lateralAccelMeta,
        ),
      );
    }
    if (data.containsKey('gps_speed')) {
      context.handle(
        _gpsSpeedMeta,
        gpsSpeed.isAcceptableOrUnknown(data['gps_speed']!, _gpsSpeedMeta),
      );
    }
    if (data.containsKey('gps_lat')) {
      context.handle(
        _gpsLatMeta,
        gpsLat.isAcceptableOrUnknown(data['gps_lat']!, _gpsLatMeta),
      );
    }
    if (data.containsKey('gps_lon')) {
      context.handle(
        _gpsLonMeta,
        gpsLon.isAcceptableOrUnknown(data['gps_lon']!, _gpsLonMeta),
      );
    }
    if (data.containsKey('gps_heading')) {
      context.handle(
        _gpsHeadingMeta,
        gpsHeading.isAcceptableOrUnknown(data['gps_heading']!, _gpsHeadingMeta),
      );
    }
    if (data.containsKey('gps_altitude')) {
      context.handle(
        _gpsAltitudeMeta,
        gpsAltitude.isAcceptableOrUnknown(
          data['gps_altitude']!,
          _gpsAltitudeMeta,
        ),
      );
    }
    if (data.containsKey('gps_accuracy')) {
      context.handle(
        _gpsAccuracyMeta,
        gpsAccuracy.isAcceptableOrUnknown(
          data['gps_accuracy']!,
          _gpsAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('gps_bearing')) {
      context.handle(
        _gpsBearingMeta,
        gpsBearing.isAcceptableOrUnknown(data['gps_bearing']!, _gpsBearingMeta),
      );
    }
    if (data.containsKey('grav_x')) {
      context.handle(
        _gravXMeta,
        gravX.isAcceptableOrUnknown(data['grav_x']!, _gravXMeta),
      );
    }
    if (data.containsKey('grav_y')) {
      context.handle(
        _gravYMeta,
        gravY.isAcceptableOrUnknown(data['grav_y']!, _gravYMeta),
      );
    }
    if (data.containsKey('grav_z')) {
      context.handle(
        _gravZMeta,
        gravZ.isAcceptableOrUnknown(data['grav_z']!, _gravZMeta),
      );
    }
    if (data.containsKey('pressure')) {
      context.handle(
        _pressureMeta,
        pressure.isAcceptableOrUnknown(data['pressure']!, _pressureMeta),
      );
    }
    if (data.containsKey('quat_w')) {
      context.handle(
        _quatWMeta,
        quatW.isAcceptableOrUnknown(data['quat_w']!, _quatWMeta),
      );
    }
    if (data.containsKey('quat_x')) {
      context.handle(
        _quatXMeta,
        quatX.isAcceptableOrUnknown(data['quat_x']!, _quatXMeta),
      );
    }
    if (data.containsKey('quat_y')) {
      context.handle(
        _quatYMeta,
        quatY.isAcceptableOrUnknown(data['quat_y']!, _quatYMeta),
      );
    }
    if (data.containsKey('quat_z')) {
      context.handle(
        _quatZMeta,
        quatZ.isAcceptableOrUnknown(data['quat_z']!, _quatZMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recording_id'],
      )!,
      timestampUs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_us'],
      )!,
      accelX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_x'],
      ),
      accelY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_y'],
      ),
      accelZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_z'],
      ),
      linearAccelX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}linear_accel_x'],
      ),
      linearAccelY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}linear_accel_y'],
      ),
      linearAccelZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}linear_accel_z'],
      ),
      gyroX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyro_x'],
      ),
      gyroY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyro_y'],
      ),
      gyroZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyro_z'],
      ),
      forwardAccel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}forward_accel'],
      ),
      lateralAccel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lateral_accel'],
      ),
      gpsSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_speed'],
      ),
      gpsLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_lat'],
      ),
      gpsLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_lon'],
      ),
      gpsHeading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_heading'],
      ),
      gpsAltitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_altitude'],
      ),
      gpsAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_accuracy'],
      ),
      gpsBearing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_bearing'],
      ),
      gravX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grav_x'],
      ),
      gravY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grav_y'],
      ),
      gravZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grav_z'],
      ),
      pressure: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pressure'],
      ),
      quatW: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_w'],
      ),
      quatX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_x'],
      ),
      quatY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_y'],
      ),
      quatZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quat_z'],
      ),
    );
  }

  @override
  $SensorSamplesTable createAlias(String alias) {
    return $SensorSamplesTable(attachedDatabase, alias);
  }
}

class SensorSample extends DataClass implements Insertable<SensorSample> {
  final int id;
  final int recordingId;
  final int timestampUs;
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final double? linearAccelX;
  final double? linearAccelY;
  final double? linearAccelZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;
  final double? forwardAccel;
  final double? lateralAccel;
  final double? gpsSpeed;
  final double? gpsLat;
  final double? gpsLon;
  final double? gpsHeading;
  final double? gpsAltitude;
  final double? gpsAccuracy;
  final double? gpsBearing;
  final double? gravX;
  final double? gravY;
  final double? gravZ;
  final double? pressure;
  final double? quatW;
  final double? quatX;
  final double? quatY;
  final double? quatZ;
  const SensorSample({
    required this.id,
    required this.recordingId,
    required this.timestampUs,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.linearAccelX,
    this.linearAccelY,
    this.linearAccelZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.forwardAccel,
    this.lateralAccel,
    this.gpsSpeed,
    this.gpsLat,
    this.gpsLon,
    this.gpsHeading,
    this.gpsAltitude,
    this.gpsAccuracy,
    this.gpsBearing,
    this.gravX,
    this.gravY,
    this.gravZ,
    this.pressure,
    this.quatW,
    this.quatX,
    this.quatY,
    this.quatZ,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recording_id'] = Variable<int>(recordingId);
    map['timestamp_us'] = Variable<int>(timestampUs);
    if (!nullToAbsent || accelX != null) {
      map['accel_x'] = Variable<double>(accelX);
    }
    if (!nullToAbsent || accelY != null) {
      map['accel_y'] = Variable<double>(accelY);
    }
    if (!nullToAbsent || accelZ != null) {
      map['accel_z'] = Variable<double>(accelZ);
    }
    if (!nullToAbsent || linearAccelX != null) {
      map['linear_accel_x'] = Variable<double>(linearAccelX);
    }
    if (!nullToAbsent || linearAccelY != null) {
      map['linear_accel_y'] = Variable<double>(linearAccelY);
    }
    if (!nullToAbsent || linearAccelZ != null) {
      map['linear_accel_z'] = Variable<double>(linearAccelZ);
    }
    if (!nullToAbsent || gyroX != null) {
      map['gyro_x'] = Variable<double>(gyroX);
    }
    if (!nullToAbsent || gyroY != null) {
      map['gyro_y'] = Variable<double>(gyroY);
    }
    if (!nullToAbsent || gyroZ != null) {
      map['gyro_z'] = Variable<double>(gyroZ);
    }
    if (!nullToAbsent || forwardAccel != null) {
      map['forward_accel'] = Variable<double>(forwardAccel);
    }
    if (!nullToAbsent || lateralAccel != null) {
      map['lateral_accel'] = Variable<double>(lateralAccel);
    }
    if (!nullToAbsent || gpsSpeed != null) {
      map['gps_speed'] = Variable<double>(gpsSpeed);
    }
    if (!nullToAbsent || gpsLat != null) {
      map['gps_lat'] = Variable<double>(gpsLat);
    }
    if (!nullToAbsent || gpsLon != null) {
      map['gps_lon'] = Variable<double>(gpsLon);
    }
    if (!nullToAbsent || gpsHeading != null) {
      map['gps_heading'] = Variable<double>(gpsHeading);
    }
    if (!nullToAbsent || gpsAltitude != null) {
      map['gps_altitude'] = Variable<double>(gpsAltitude);
    }
    if (!nullToAbsent || gpsAccuracy != null) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy);
    }
    if (!nullToAbsent || gpsBearing != null) {
      map['gps_bearing'] = Variable<double>(gpsBearing);
    }
    if (!nullToAbsent || gravX != null) {
      map['grav_x'] = Variable<double>(gravX);
    }
    if (!nullToAbsent || gravY != null) {
      map['grav_y'] = Variable<double>(gravY);
    }
    if (!nullToAbsent || gravZ != null) {
      map['grav_z'] = Variable<double>(gravZ);
    }
    if (!nullToAbsent || pressure != null) {
      map['pressure'] = Variable<double>(pressure);
    }
    if (!nullToAbsent || quatW != null) {
      map['quat_w'] = Variable<double>(quatW);
    }
    if (!nullToAbsent || quatX != null) {
      map['quat_x'] = Variable<double>(quatX);
    }
    if (!nullToAbsent || quatY != null) {
      map['quat_y'] = Variable<double>(quatY);
    }
    if (!nullToAbsent || quatZ != null) {
      map['quat_z'] = Variable<double>(quatZ);
    }
    return map;
  }

  SensorSamplesCompanion toCompanion(bool nullToAbsent) {
    return SensorSamplesCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      timestampUs: Value(timestampUs),
      accelX: accelX == null && nullToAbsent
          ? const Value.absent()
          : Value(accelX),
      accelY: accelY == null && nullToAbsent
          ? const Value.absent()
          : Value(accelY),
      accelZ: accelZ == null && nullToAbsent
          ? const Value.absent()
          : Value(accelZ),
      linearAccelX: linearAccelX == null && nullToAbsent
          ? const Value.absent()
          : Value(linearAccelX),
      linearAccelY: linearAccelY == null && nullToAbsent
          ? const Value.absent()
          : Value(linearAccelY),
      linearAccelZ: linearAccelZ == null && nullToAbsent
          ? const Value.absent()
          : Value(linearAccelZ),
      gyroX: gyroX == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroX),
      gyroY: gyroY == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroY),
      gyroZ: gyroZ == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroZ),
      forwardAccel: forwardAccel == null && nullToAbsent
          ? const Value.absent()
          : Value(forwardAccel),
      lateralAccel: lateralAccel == null && nullToAbsent
          ? const Value.absent()
          : Value(lateralAccel),
      gpsSpeed: gpsSpeed == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsSpeed),
      gpsLat: gpsLat == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLat),
      gpsLon: gpsLon == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLon),
      gpsHeading: gpsHeading == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsHeading),
      gpsAltitude: gpsAltitude == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAltitude),
      gpsAccuracy: gpsAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracy),
      gpsBearing: gpsBearing == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsBearing),
      gravX: gravX == null && nullToAbsent
          ? const Value.absent()
          : Value(gravX),
      gravY: gravY == null && nullToAbsent
          ? const Value.absent()
          : Value(gravY),
      gravZ: gravZ == null && nullToAbsent
          ? const Value.absent()
          : Value(gravZ),
      pressure: pressure == null && nullToAbsent
          ? const Value.absent()
          : Value(pressure),
      quatW: quatW == null && nullToAbsent
          ? const Value.absent()
          : Value(quatW),
      quatX: quatX == null && nullToAbsent
          ? const Value.absent()
          : Value(quatX),
      quatY: quatY == null && nullToAbsent
          ? const Value.absent()
          : Value(quatY),
      quatZ: quatZ == null && nullToAbsent
          ? const Value.absent()
          : Value(quatZ),
    );
  }

  factory SensorSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorSample(
      id: serializer.fromJson<int>(json['id']),
      recordingId: serializer.fromJson<int>(json['recordingId']),
      timestampUs: serializer.fromJson<int>(json['timestampUs']),
      accelX: serializer.fromJson<double?>(json['accelX']),
      accelY: serializer.fromJson<double?>(json['accelY']),
      accelZ: serializer.fromJson<double?>(json['accelZ']),
      linearAccelX: serializer.fromJson<double?>(json['linearAccelX']),
      linearAccelY: serializer.fromJson<double?>(json['linearAccelY']),
      linearAccelZ: serializer.fromJson<double?>(json['linearAccelZ']),
      gyroX: serializer.fromJson<double?>(json['gyroX']),
      gyroY: serializer.fromJson<double?>(json['gyroY']),
      gyroZ: serializer.fromJson<double?>(json['gyroZ']),
      forwardAccel: serializer.fromJson<double?>(json['forwardAccel']),
      lateralAccel: serializer.fromJson<double?>(json['lateralAccel']),
      gpsSpeed: serializer.fromJson<double?>(json['gpsSpeed']),
      gpsLat: serializer.fromJson<double?>(json['gpsLat']),
      gpsLon: serializer.fromJson<double?>(json['gpsLon']),
      gpsHeading: serializer.fromJson<double?>(json['gpsHeading']),
      gpsAltitude: serializer.fromJson<double?>(json['gpsAltitude']),
      gpsAccuracy: serializer.fromJson<double?>(json['gpsAccuracy']),
      gpsBearing: serializer.fromJson<double?>(json['gpsBearing']),
      gravX: serializer.fromJson<double?>(json['gravX']),
      gravY: serializer.fromJson<double?>(json['gravY']),
      gravZ: serializer.fromJson<double?>(json['gravZ']),
      pressure: serializer.fromJson<double?>(json['pressure']),
      quatW: serializer.fromJson<double?>(json['quatW']),
      quatX: serializer.fromJson<double?>(json['quatX']),
      quatY: serializer.fromJson<double?>(json['quatY']),
      quatZ: serializer.fromJson<double?>(json['quatZ']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordingId': serializer.toJson<int>(recordingId),
      'timestampUs': serializer.toJson<int>(timestampUs),
      'accelX': serializer.toJson<double?>(accelX),
      'accelY': serializer.toJson<double?>(accelY),
      'accelZ': serializer.toJson<double?>(accelZ),
      'linearAccelX': serializer.toJson<double?>(linearAccelX),
      'linearAccelY': serializer.toJson<double?>(linearAccelY),
      'linearAccelZ': serializer.toJson<double?>(linearAccelZ),
      'gyroX': serializer.toJson<double?>(gyroX),
      'gyroY': serializer.toJson<double?>(gyroY),
      'gyroZ': serializer.toJson<double?>(gyroZ),
      'forwardAccel': serializer.toJson<double?>(forwardAccel),
      'lateralAccel': serializer.toJson<double?>(lateralAccel),
      'gpsSpeed': serializer.toJson<double?>(gpsSpeed),
      'gpsLat': serializer.toJson<double?>(gpsLat),
      'gpsLon': serializer.toJson<double?>(gpsLon),
      'gpsHeading': serializer.toJson<double?>(gpsHeading),
      'gpsAltitude': serializer.toJson<double?>(gpsAltitude),
      'gpsAccuracy': serializer.toJson<double?>(gpsAccuracy),
      'gpsBearing': serializer.toJson<double?>(gpsBearing),
      'gravX': serializer.toJson<double?>(gravX),
      'gravY': serializer.toJson<double?>(gravY),
      'gravZ': serializer.toJson<double?>(gravZ),
      'pressure': serializer.toJson<double?>(pressure),
      'quatW': serializer.toJson<double?>(quatW),
      'quatX': serializer.toJson<double?>(quatX),
      'quatY': serializer.toJson<double?>(quatY),
      'quatZ': serializer.toJson<double?>(quatZ),
    };
  }

  SensorSample copyWith({
    int? id,
    int? recordingId,
    int? timestampUs,
    Value<double?> accelX = const Value.absent(),
    Value<double?> accelY = const Value.absent(),
    Value<double?> accelZ = const Value.absent(),
    Value<double?> linearAccelX = const Value.absent(),
    Value<double?> linearAccelY = const Value.absent(),
    Value<double?> linearAccelZ = const Value.absent(),
    Value<double?> gyroX = const Value.absent(),
    Value<double?> gyroY = const Value.absent(),
    Value<double?> gyroZ = const Value.absent(),
    Value<double?> forwardAccel = const Value.absent(),
    Value<double?> lateralAccel = const Value.absent(),
    Value<double?> gpsSpeed = const Value.absent(),
    Value<double?> gpsLat = const Value.absent(),
    Value<double?> gpsLon = const Value.absent(),
    Value<double?> gpsHeading = const Value.absent(),
    Value<double?> gpsAltitude = const Value.absent(),
    Value<double?> gpsAccuracy = const Value.absent(),
    Value<double?> gpsBearing = const Value.absent(),
    Value<double?> gravX = const Value.absent(),
    Value<double?> gravY = const Value.absent(),
    Value<double?> gravZ = const Value.absent(),
    Value<double?> pressure = const Value.absent(),
    Value<double?> quatW = const Value.absent(),
    Value<double?> quatX = const Value.absent(),
    Value<double?> quatY = const Value.absent(),
    Value<double?> quatZ = const Value.absent(),
  }) => SensorSample(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    timestampUs: timestampUs ?? this.timestampUs,
    accelX: accelX.present ? accelX.value : this.accelX,
    accelY: accelY.present ? accelY.value : this.accelY,
    accelZ: accelZ.present ? accelZ.value : this.accelZ,
    linearAccelX: linearAccelX.present ? linearAccelX.value : this.linearAccelX,
    linearAccelY: linearAccelY.present ? linearAccelY.value : this.linearAccelY,
    linearAccelZ: linearAccelZ.present ? linearAccelZ.value : this.linearAccelZ,
    gyroX: gyroX.present ? gyroX.value : this.gyroX,
    gyroY: gyroY.present ? gyroY.value : this.gyroY,
    gyroZ: gyroZ.present ? gyroZ.value : this.gyroZ,
    forwardAccel: forwardAccel.present ? forwardAccel.value : this.forwardAccel,
    lateralAccel: lateralAccel.present ? lateralAccel.value : this.lateralAccel,
    gpsSpeed: gpsSpeed.present ? gpsSpeed.value : this.gpsSpeed,
    gpsLat: gpsLat.present ? gpsLat.value : this.gpsLat,
    gpsLon: gpsLon.present ? gpsLon.value : this.gpsLon,
    gpsHeading: gpsHeading.present ? gpsHeading.value : this.gpsHeading,
    gpsAltitude: gpsAltitude.present ? gpsAltitude.value : this.gpsAltitude,
    gpsAccuracy: gpsAccuracy.present ? gpsAccuracy.value : this.gpsAccuracy,
    gpsBearing: gpsBearing.present ? gpsBearing.value : this.gpsBearing,
    gravX: gravX.present ? gravX.value : this.gravX,
    gravY: gravY.present ? gravY.value : this.gravY,
    gravZ: gravZ.present ? gravZ.value : this.gravZ,
    pressure: pressure.present ? pressure.value : this.pressure,
    quatW: quatW.present ? quatW.value : this.quatW,
    quatX: quatX.present ? quatX.value : this.quatX,
    quatY: quatY.present ? quatY.value : this.quatY,
    quatZ: quatZ.present ? quatZ.value : this.quatZ,
  );
  SensorSample copyWithCompanion(SensorSamplesCompanion data) {
    return SensorSample(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      timestampUs: data.timestampUs.present
          ? data.timestampUs.value
          : this.timestampUs,
      accelX: data.accelX.present ? data.accelX.value : this.accelX,
      accelY: data.accelY.present ? data.accelY.value : this.accelY,
      accelZ: data.accelZ.present ? data.accelZ.value : this.accelZ,
      linearAccelX: data.linearAccelX.present
          ? data.linearAccelX.value
          : this.linearAccelX,
      linearAccelY: data.linearAccelY.present
          ? data.linearAccelY.value
          : this.linearAccelY,
      linearAccelZ: data.linearAccelZ.present
          ? data.linearAccelZ.value
          : this.linearAccelZ,
      gyroX: data.gyroX.present ? data.gyroX.value : this.gyroX,
      gyroY: data.gyroY.present ? data.gyroY.value : this.gyroY,
      gyroZ: data.gyroZ.present ? data.gyroZ.value : this.gyroZ,
      forwardAccel: data.forwardAccel.present
          ? data.forwardAccel.value
          : this.forwardAccel,
      lateralAccel: data.lateralAccel.present
          ? data.lateralAccel.value
          : this.lateralAccel,
      gpsSpeed: data.gpsSpeed.present ? data.gpsSpeed.value : this.gpsSpeed,
      gpsLat: data.gpsLat.present ? data.gpsLat.value : this.gpsLat,
      gpsLon: data.gpsLon.present ? data.gpsLon.value : this.gpsLon,
      gpsHeading: data.gpsHeading.present
          ? data.gpsHeading.value
          : this.gpsHeading,
      gpsAltitude: data.gpsAltitude.present
          ? data.gpsAltitude.value
          : this.gpsAltitude,
      gpsAccuracy: data.gpsAccuracy.present
          ? data.gpsAccuracy.value
          : this.gpsAccuracy,
      gpsBearing: data.gpsBearing.present
          ? data.gpsBearing.value
          : this.gpsBearing,
      gravX: data.gravX.present ? data.gravX.value : this.gravX,
      gravY: data.gravY.present ? data.gravY.value : this.gravY,
      gravZ: data.gravZ.present ? data.gravZ.value : this.gravZ,
      pressure: data.pressure.present ? data.pressure.value : this.pressure,
      quatW: data.quatW.present ? data.quatW.value : this.quatW,
      quatX: data.quatX.present ? data.quatX.value : this.quatX,
      quatY: data.quatY.present ? data.quatY.value : this.quatY,
      quatZ: data.quatZ.present ? data.quatZ.value : this.quatZ,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorSample(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('timestampUs: $timestampUs, ')
          ..write('accelX: $accelX, ')
          ..write('accelY: $accelY, ')
          ..write('accelZ: $accelZ, ')
          ..write('linearAccelX: $linearAccelX, ')
          ..write('linearAccelY: $linearAccelY, ')
          ..write('linearAccelZ: $linearAccelZ, ')
          ..write('gyroX: $gyroX, ')
          ..write('gyroY: $gyroY, ')
          ..write('gyroZ: $gyroZ, ')
          ..write('forwardAccel: $forwardAccel, ')
          ..write('lateralAccel: $lateralAccel, ')
          ..write('gpsSpeed: $gpsSpeed, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLon: $gpsLon, ')
          ..write('gpsHeading: $gpsHeading, ')
          ..write('gpsAltitude: $gpsAltitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('gpsBearing: $gpsBearing, ')
          ..write('gravX: $gravX, ')
          ..write('gravY: $gravY, ')
          ..write('gravZ: $gravZ, ')
          ..write('pressure: $pressure, ')
          ..write('quatW: $quatW, ')
          ..write('quatX: $quatX, ')
          ..write('quatY: $quatY, ')
          ..write('quatZ: $quatZ')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    recordingId,
    timestampUs,
    accelX,
    accelY,
    accelZ,
    linearAccelX,
    linearAccelY,
    linearAccelZ,
    gyroX,
    gyroY,
    gyroZ,
    forwardAccel,
    lateralAccel,
    gpsSpeed,
    gpsLat,
    gpsLon,
    gpsHeading,
    gpsAltitude,
    gpsAccuracy,
    gpsBearing,
    gravX,
    gravY,
    gravZ,
    pressure,
    quatW,
    quatX,
    quatY,
    quatZ,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorSample &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.timestampUs == this.timestampUs &&
          other.accelX == this.accelX &&
          other.accelY == this.accelY &&
          other.accelZ == this.accelZ &&
          other.linearAccelX == this.linearAccelX &&
          other.linearAccelY == this.linearAccelY &&
          other.linearAccelZ == this.linearAccelZ &&
          other.gyroX == this.gyroX &&
          other.gyroY == this.gyroY &&
          other.gyroZ == this.gyroZ &&
          other.forwardAccel == this.forwardAccel &&
          other.lateralAccel == this.lateralAccel &&
          other.gpsSpeed == this.gpsSpeed &&
          other.gpsLat == this.gpsLat &&
          other.gpsLon == this.gpsLon &&
          other.gpsHeading == this.gpsHeading &&
          other.gpsAltitude == this.gpsAltitude &&
          other.gpsAccuracy == this.gpsAccuracy &&
          other.gpsBearing == this.gpsBearing &&
          other.gravX == this.gravX &&
          other.gravY == this.gravY &&
          other.gravZ == this.gravZ &&
          other.pressure == this.pressure &&
          other.quatW == this.quatW &&
          other.quatX == this.quatX &&
          other.quatY == this.quatY &&
          other.quatZ == this.quatZ);
}

class SensorSamplesCompanion extends UpdateCompanion<SensorSample> {
  final Value<int> id;
  final Value<int> recordingId;
  final Value<int> timestampUs;
  final Value<double?> accelX;
  final Value<double?> accelY;
  final Value<double?> accelZ;
  final Value<double?> linearAccelX;
  final Value<double?> linearAccelY;
  final Value<double?> linearAccelZ;
  final Value<double?> gyroX;
  final Value<double?> gyroY;
  final Value<double?> gyroZ;
  final Value<double?> forwardAccel;
  final Value<double?> lateralAccel;
  final Value<double?> gpsSpeed;
  final Value<double?> gpsLat;
  final Value<double?> gpsLon;
  final Value<double?> gpsHeading;
  final Value<double?> gpsAltitude;
  final Value<double?> gpsAccuracy;
  final Value<double?> gpsBearing;
  final Value<double?> gravX;
  final Value<double?> gravY;
  final Value<double?> gravZ;
  final Value<double?> pressure;
  final Value<double?> quatW;
  final Value<double?> quatX;
  final Value<double?> quatY;
  final Value<double?> quatZ;
  const SensorSamplesCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.timestampUs = const Value.absent(),
    this.accelX = const Value.absent(),
    this.accelY = const Value.absent(),
    this.accelZ = const Value.absent(),
    this.linearAccelX = const Value.absent(),
    this.linearAccelY = const Value.absent(),
    this.linearAccelZ = const Value.absent(),
    this.gyroX = const Value.absent(),
    this.gyroY = const Value.absent(),
    this.gyroZ = const Value.absent(),
    this.forwardAccel = const Value.absent(),
    this.lateralAccel = const Value.absent(),
    this.gpsSpeed = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLon = const Value.absent(),
    this.gpsHeading = const Value.absent(),
    this.gpsAltitude = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.gpsBearing = const Value.absent(),
    this.gravX = const Value.absent(),
    this.gravY = const Value.absent(),
    this.gravZ = const Value.absent(),
    this.pressure = const Value.absent(),
    this.quatW = const Value.absent(),
    this.quatX = const Value.absent(),
    this.quatY = const Value.absent(),
    this.quatZ = const Value.absent(),
  });
  SensorSamplesCompanion.insert({
    this.id = const Value.absent(),
    required int recordingId,
    required int timestampUs,
    this.accelX = const Value.absent(),
    this.accelY = const Value.absent(),
    this.accelZ = const Value.absent(),
    this.linearAccelX = const Value.absent(),
    this.linearAccelY = const Value.absent(),
    this.linearAccelZ = const Value.absent(),
    this.gyroX = const Value.absent(),
    this.gyroY = const Value.absent(),
    this.gyroZ = const Value.absent(),
    this.forwardAccel = const Value.absent(),
    this.lateralAccel = const Value.absent(),
    this.gpsSpeed = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLon = const Value.absent(),
    this.gpsHeading = const Value.absent(),
    this.gpsAltitude = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.gpsBearing = const Value.absent(),
    this.gravX = const Value.absent(),
    this.gravY = const Value.absent(),
    this.gravZ = const Value.absent(),
    this.pressure = const Value.absent(),
    this.quatW = const Value.absent(),
    this.quatX = const Value.absent(),
    this.quatY = const Value.absent(),
    this.quatZ = const Value.absent(),
  }) : recordingId = Value(recordingId),
       timestampUs = Value(timestampUs);
  static Insertable<SensorSample> custom({
    Expression<int>? id,
    Expression<int>? recordingId,
    Expression<int>? timestampUs,
    Expression<double>? accelX,
    Expression<double>? accelY,
    Expression<double>? accelZ,
    Expression<double>? linearAccelX,
    Expression<double>? linearAccelY,
    Expression<double>? linearAccelZ,
    Expression<double>? gyroX,
    Expression<double>? gyroY,
    Expression<double>? gyroZ,
    Expression<double>? forwardAccel,
    Expression<double>? lateralAccel,
    Expression<double>? gpsSpeed,
    Expression<double>? gpsLat,
    Expression<double>? gpsLon,
    Expression<double>? gpsHeading,
    Expression<double>? gpsAltitude,
    Expression<double>? gpsAccuracy,
    Expression<double>? gpsBearing,
    Expression<double>? gravX,
    Expression<double>? gravY,
    Expression<double>? gravZ,
    Expression<double>? pressure,
    Expression<double>? quatW,
    Expression<double>? quatX,
    Expression<double>? quatY,
    Expression<double>? quatZ,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (timestampUs != null) 'timestamp_us': timestampUs,
      if (accelX != null) 'accel_x': accelX,
      if (accelY != null) 'accel_y': accelY,
      if (accelZ != null) 'accel_z': accelZ,
      if (linearAccelX != null) 'linear_accel_x': linearAccelX,
      if (linearAccelY != null) 'linear_accel_y': linearAccelY,
      if (linearAccelZ != null) 'linear_accel_z': linearAccelZ,
      if (gyroX != null) 'gyro_x': gyroX,
      if (gyroY != null) 'gyro_y': gyroY,
      if (gyroZ != null) 'gyro_z': gyroZ,
      if (forwardAccel != null) 'forward_accel': forwardAccel,
      if (lateralAccel != null) 'lateral_accel': lateralAccel,
      if (gpsSpeed != null) 'gps_speed': gpsSpeed,
      if (gpsLat != null) 'gps_lat': gpsLat,
      if (gpsLon != null) 'gps_lon': gpsLon,
      if (gpsHeading != null) 'gps_heading': gpsHeading,
      if (gpsAltitude != null) 'gps_altitude': gpsAltitude,
      if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
      if (gpsBearing != null) 'gps_bearing': gpsBearing,
      if (gravX != null) 'grav_x': gravX,
      if (gravY != null) 'grav_y': gravY,
      if (gravZ != null) 'grav_z': gravZ,
      if (pressure != null) 'pressure': pressure,
      if (quatW != null) 'quat_w': quatW,
      if (quatX != null) 'quat_x': quatX,
      if (quatY != null) 'quat_y': quatY,
      if (quatZ != null) 'quat_z': quatZ,
    });
  }

  SensorSamplesCompanion copyWith({
    Value<int>? id,
    Value<int>? recordingId,
    Value<int>? timestampUs,
    Value<double?>? accelX,
    Value<double?>? accelY,
    Value<double?>? accelZ,
    Value<double?>? linearAccelX,
    Value<double?>? linearAccelY,
    Value<double?>? linearAccelZ,
    Value<double?>? gyroX,
    Value<double?>? gyroY,
    Value<double?>? gyroZ,
    Value<double?>? forwardAccel,
    Value<double?>? lateralAccel,
    Value<double?>? gpsSpeed,
    Value<double?>? gpsLat,
    Value<double?>? gpsLon,
    Value<double?>? gpsHeading,
    Value<double?>? gpsAltitude,
    Value<double?>? gpsAccuracy,
    Value<double?>? gpsBearing,
    Value<double?>? gravX,
    Value<double?>? gravY,
    Value<double?>? gravZ,
    Value<double?>? pressure,
    Value<double?>? quatW,
    Value<double?>? quatX,
    Value<double?>? quatY,
    Value<double?>? quatZ,
  }) {
    return SensorSamplesCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      timestampUs: timestampUs ?? this.timestampUs,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      linearAccelX: linearAccelX ?? this.linearAccelX,
      linearAccelY: linearAccelY ?? this.linearAccelY,
      linearAccelZ: linearAccelZ ?? this.linearAccelZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      forwardAccel: forwardAccel ?? this.forwardAccel,
      lateralAccel: lateralAccel ?? this.lateralAccel,
      gpsSpeed: gpsSpeed ?? this.gpsSpeed,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLon: gpsLon ?? this.gpsLon,
      gpsHeading: gpsHeading ?? this.gpsHeading,
      gpsAltitude: gpsAltitude ?? this.gpsAltitude,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      gpsBearing: gpsBearing ?? this.gpsBearing,
      gravX: gravX ?? this.gravX,
      gravY: gravY ?? this.gravY,
      gravZ: gravZ ?? this.gravZ,
      pressure: pressure ?? this.pressure,
      quatW: quatW ?? this.quatW,
      quatX: quatX ?? this.quatX,
      quatY: quatY ?? this.quatY,
      quatZ: quatZ ?? this.quatZ,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<int>(recordingId.value);
    }
    if (timestampUs.present) {
      map['timestamp_us'] = Variable<int>(timestampUs.value);
    }
    if (accelX.present) {
      map['accel_x'] = Variable<double>(accelX.value);
    }
    if (accelY.present) {
      map['accel_y'] = Variable<double>(accelY.value);
    }
    if (accelZ.present) {
      map['accel_z'] = Variable<double>(accelZ.value);
    }
    if (linearAccelX.present) {
      map['linear_accel_x'] = Variable<double>(linearAccelX.value);
    }
    if (linearAccelY.present) {
      map['linear_accel_y'] = Variable<double>(linearAccelY.value);
    }
    if (linearAccelZ.present) {
      map['linear_accel_z'] = Variable<double>(linearAccelZ.value);
    }
    if (gyroX.present) {
      map['gyro_x'] = Variable<double>(gyroX.value);
    }
    if (gyroY.present) {
      map['gyro_y'] = Variable<double>(gyroY.value);
    }
    if (gyroZ.present) {
      map['gyro_z'] = Variable<double>(gyroZ.value);
    }
    if (forwardAccel.present) {
      map['forward_accel'] = Variable<double>(forwardAccel.value);
    }
    if (lateralAccel.present) {
      map['lateral_accel'] = Variable<double>(lateralAccel.value);
    }
    if (gpsSpeed.present) {
      map['gps_speed'] = Variable<double>(gpsSpeed.value);
    }
    if (gpsLat.present) {
      map['gps_lat'] = Variable<double>(gpsLat.value);
    }
    if (gpsLon.present) {
      map['gps_lon'] = Variable<double>(gpsLon.value);
    }
    if (gpsHeading.present) {
      map['gps_heading'] = Variable<double>(gpsHeading.value);
    }
    if (gpsAltitude.present) {
      map['gps_altitude'] = Variable<double>(gpsAltitude.value);
    }
    if (gpsAccuracy.present) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy.value);
    }
    if (gpsBearing.present) {
      map['gps_bearing'] = Variable<double>(gpsBearing.value);
    }
    if (gravX.present) {
      map['grav_x'] = Variable<double>(gravX.value);
    }
    if (gravY.present) {
      map['grav_y'] = Variable<double>(gravY.value);
    }
    if (gravZ.present) {
      map['grav_z'] = Variable<double>(gravZ.value);
    }
    if (pressure.present) {
      map['pressure'] = Variable<double>(pressure.value);
    }
    if (quatW.present) {
      map['quat_w'] = Variable<double>(quatW.value);
    }
    if (quatX.present) {
      map['quat_x'] = Variable<double>(quatX.value);
    }
    if (quatY.present) {
      map['quat_y'] = Variable<double>(quatY.value);
    }
    if (quatZ.present) {
      map['quat_z'] = Variable<double>(quatZ.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorSamplesCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('timestampUs: $timestampUs, ')
          ..write('accelX: $accelX, ')
          ..write('accelY: $accelY, ')
          ..write('accelZ: $accelZ, ')
          ..write('linearAccelX: $linearAccelX, ')
          ..write('linearAccelY: $linearAccelY, ')
          ..write('linearAccelZ: $linearAccelZ, ')
          ..write('gyroX: $gyroX, ')
          ..write('gyroY: $gyroY, ')
          ..write('gyroZ: $gyroZ, ')
          ..write('forwardAccel: $forwardAccel, ')
          ..write('lateralAccel: $lateralAccel, ')
          ..write('gpsSpeed: $gpsSpeed, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLon: $gpsLon, ')
          ..write('gpsHeading: $gpsHeading, ')
          ..write('gpsAltitude: $gpsAltitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('gpsBearing: $gpsBearing, ')
          ..write('gravX: $gravX, ')
          ..write('gravY: $gravY, ')
          ..write('gravZ: $gravZ, ')
          ..write('pressure: $pressure, ')
          ..write('quatW: $quatW, ')
          ..write('quatX: $quatX, ')
          ..write('quatY: $quatY, ')
          ..write('quatZ: $quatZ')
          ..write(')'))
        .toString();
  }
}

class $CarProfilesTable extends CarProfiles
    with TableInfo<$CarProfilesTable, CarProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _transmissionMeta = const VerificationMeta(
    'transmission',
  );
  @override
  late final GeneratedColumn<String> transmission = GeneratedColumn<String>(
    'transmission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    make,
    model,
    year,
    fuelType,
    transmission,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'car_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    }
    if (data.containsKey('transmission')) {
      context.handle(
        _transmissionMeta,
        transmission.isAcceptableOrUnknown(
          data['transmission']!,
          _transmissionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      )!,
      transmission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transmission'],
      )!,
    );
  }

  @override
  $CarProfilesTable createAlias(String alias) {
    return $CarProfilesTable(attachedDatabase, alias);
  }
}

class CarProfile extends DataClass implements Insertable<CarProfile> {
  final int id;
  final String name;
  final String make;
  final String model;
  final int? year;
  final String fuelType;
  final String transmission;
  const CarProfile({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    this.year,
    required this.fuelType,
    required this.transmission,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['fuel_type'] = Variable<String>(fuelType);
    map['transmission'] = Variable<String>(transmission);
    return map;
  }

  CarProfilesCompanion toCompanion(bool nullToAbsent) {
    return CarProfilesCompanion(
      id: Value(id),
      name: Value(name),
      make: Value(make),
      model: Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      fuelType: Value(fuelType),
      transmission: Value(transmission),
    );
  }

  factory CarProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<int?>(json['year']),
      fuelType: serializer.fromJson<String>(json['fuelType']),
      transmission: serializer.fromJson<String>(json['transmission']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<int?>(year),
      'fuelType': serializer.toJson<String>(fuelType),
      'transmission': serializer.toJson<String>(transmission),
    };
  }

  CarProfile copyWith({
    int? id,
    String? name,
    String? make,
    String? model,
    Value<int?> year = const Value.absent(),
    String? fuelType,
    String? transmission,
  }) => CarProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    make: make ?? this.make,
    model: model ?? this.model,
    year: year.present ? year.value : this.year,
    fuelType: fuelType ?? this.fuelType,
    transmission: transmission ?? this.transmission,
  );
  CarProfile copyWithCompanion(CarProfilesCompanion data) {
    return CarProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      transmission: data.transmission.present
          ? data.transmission.value
          : this.transmission,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('transmission: $transmission')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, make, model, year, fuelType, transmission);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.fuelType == this.fuelType &&
          other.transmission == this.transmission);
}

class CarProfilesCompanion extends UpdateCompanion<CarProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> make;
  final Value<String> model;
  final Value<int?> year;
  final Value<String> fuelType;
  final Value<String> transmission;
  const CarProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.transmission = const Value.absent(),
  });
  CarProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.transmission = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CarProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<String>? fuelType,
    Expression<String>? transmission,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (fuelType != null) 'fuel_type': fuelType,
      if (transmission != null) 'transmission': transmission,
    });
  }

  CarProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? make,
    Value<String>? model,
    Value<int?>? year,
    Value<String>? fuelType,
    Value<String>? transmission,
  }) {
    return CarProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (transmission.present) {
      map['transmission'] = Variable<String>(transmission.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('fuelType: $fuelType, ')
          ..write('transmission: $transmission')
          ..write(')'))
        .toString();
  }
}

class $RecordingMetadataTable extends RecordingMetadata
    with TableInfo<$RecordingMetadataTable, RecordingMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordingMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<int> recordingId = GeneratedColumn<int>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recordings (id)',
    ),
  );
  static const VerificationMeta _carProfileIdMeta = const VerificationMeta(
    'carProfileId',
  );
  @override
  late final GeneratedColumn<int> carProfileId = GeneratedColumn<int>(
    'car_profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES car_profiles (id)',
    ),
  );
  static const VerificationMeta _driveModeMeta = const VerificationMeta(
    'driveMode',
  );
  @override
  late final GeneratedColumn<String> driveMode = GeneratedColumn<String>(
    'drive_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _passengerCountMeta = const VerificationMeta(
    'passengerCount',
  );
  @override
  late final GeneratedColumn<int> passengerCount = GeneratedColumn<int>(
    'passenger_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuelLevelPercentMeta = const VerificationMeta(
    'fuelLevelPercent',
  );
  @override
  late final GeneratedColumn<int> fuelLevelPercent = GeneratedColumn<int>(
    'fuel_level_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tyreTypeMeta = const VerificationMeta(
    'tyreType',
  );
  @override
  late final GeneratedColumn<String> tyreType = GeneratedColumn<String>(
    'tyre_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _weatherNoteMeta = const VerificationMeta(
    'weatherNote',
  );
  @override
  late final GeneratedColumn<String> weatherNote = GeneratedColumn<String>(
    'weather_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _freeTextMeta = const VerificationMeta(
    'freeText',
  );
  @override
  late final GeneratedColumn<String> freeText = GeneratedColumn<String>(
    'free_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    carProfileId,
    driveMode,
    passengerCount,
    fuelLevelPercent,
    tyreType,
    weatherNote,
    freeText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recording_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecordingMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('car_profile_id')) {
      context.handle(
        _carProfileIdMeta,
        carProfileId.isAcceptableOrUnknown(
          data['car_profile_id']!,
          _carProfileIdMeta,
        ),
      );
    }
    if (data.containsKey('drive_mode')) {
      context.handle(
        _driveModeMeta,
        driveMode.isAcceptableOrUnknown(data['drive_mode']!, _driveModeMeta),
      );
    }
    if (data.containsKey('passenger_count')) {
      context.handle(
        _passengerCountMeta,
        passengerCount.isAcceptableOrUnknown(
          data['passenger_count']!,
          _passengerCountMeta,
        ),
      );
    }
    if (data.containsKey('fuel_level_percent')) {
      context.handle(
        _fuelLevelPercentMeta,
        fuelLevelPercent.isAcceptableOrUnknown(
          data['fuel_level_percent']!,
          _fuelLevelPercentMeta,
        ),
      );
    }
    if (data.containsKey('tyre_type')) {
      context.handle(
        _tyreTypeMeta,
        tyreType.isAcceptableOrUnknown(data['tyre_type']!, _tyreTypeMeta),
      );
    }
    if (data.containsKey('weather_note')) {
      context.handle(
        _weatherNoteMeta,
        weatherNote.isAcceptableOrUnknown(
          data['weather_note']!,
          _weatherNoteMeta,
        ),
      );
    }
    if (data.containsKey('free_text')) {
      context.handle(
        _freeTextMeta,
        freeText.isAcceptableOrUnknown(data['free_text']!, _freeTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecordingMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecordingMetadataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recording_id'],
      )!,
      carProfileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}car_profile_id'],
      ),
      driveMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drive_mode'],
      )!,
      passengerCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passenger_count'],
      ),
      fuelLevelPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fuel_level_percent'],
      ),
      tyreType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tyre_type'],
      )!,
      weatherNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_note'],
      )!,
      freeText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_text'],
      )!,
    );
  }

  @override
  $RecordingMetadataTable createAlias(String alias) {
    return $RecordingMetadataTable(attachedDatabase, alias);
  }
}

class RecordingMetadataData extends DataClass
    implements Insertable<RecordingMetadataData> {
  final int id;
  final int recordingId;
  final int? carProfileId;
  final String driveMode;
  final int? passengerCount;
  final int? fuelLevelPercent;
  final String tyreType;
  final String weatherNote;
  final String freeText;
  const RecordingMetadataData({
    required this.id,
    required this.recordingId,
    this.carProfileId,
    required this.driveMode,
    this.passengerCount,
    this.fuelLevelPercent,
    required this.tyreType,
    required this.weatherNote,
    required this.freeText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recording_id'] = Variable<int>(recordingId);
    if (!nullToAbsent || carProfileId != null) {
      map['car_profile_id'] = Variable<int>(carProfileId);
    }
    map['drive_mode'] = Variable<String>(driveMode);
    if (!nullToAbsent || passengerCount != null) {
      map['passenger_count'] = Variable<int>(passengerCount);
    }
    if (!nullToAbsent || fuelLevelPercent != null) {
      map['fuel_level_percent'] = Variable<int>(fuelLevelPercent);
    }
    map['tyre_type'] = Variable<String>(tyreType);
    map['weather_note'] = Variable<String>(weatherNote);
    map['free_text'] = Variable<String>(freeText);
    return map;
  }

  RecordingMetadataCompanion toCompanion(bool nullToAbsent) {
    return RecordingMetadataCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      carProfileId: carProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(carProfileId),
      driveMode: Value(driveMode),
      passengerCount: passengerCount == null && nullToAbsent
          ? const Value.absent()
          : Value(passengerCount),
      fuelLevelPercent: fuelLevelPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelLevelPercent),
      tyreType: Value(tyreType),
      weatherNote: Value(weatherNote),
      freeText: Value(freeText),
    );
  }

  factory RecordingMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecordingMetadataData(
      id: serializer.fromJson<int>(json['id']),
      recordingId: serializer.fromJson<int>(json['recordingId']),
      carProfileId: serializer.fromJson<int?>(json['carProfileId']),
      driveMode: serializer.fromJson<String>(json['driveMode']),
      passengerCount: serializer.fromJson<int?>(json['passengerCount']),
      fuelLevelPercent: serializer.fromJson<int?>(json['fuelLevelPercent']),
      tyreType: serializer.fromJson<String>(json['tyreType']),
      weatherNote: serializer.fromJson<String>(json['weatherNote']),
      freeText: serializer.fromJson<String>(json['freeText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordingId': serializer.toJson<int>(recordingId),
      'carProfileId': serializer.toJson<int?>(carProfileId),
      'driveMode': serializer.toJson<String>(driveMode),
      'passengerCount': serializer.toJson<int?>(passengerCount),
      'fuelLevelPercent': serializer.toJson<int?>(fuelLevelPercent),
      'tyreType': serializer.toJson<String>(tyreType),
      'weatherNote': serializer.toJson<String>(weatherNote),
      'freeText': serializer.toJson<String>(freeText),
    };
  }

  RecordingMetadataData copyWith({
    int? id,
    int? recordingId,
    Value<int?> carProfileId = const Value.absent(),
    String? driveMode,
    Value<int?> passengerCount = const Value.absent(),
    Value<int?> fuelLevelPercent = const Value.absent(),
    String? tyreType,
    String? weatherNote,
    String? freeText,
  }) => RecordingMetadataData(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    carProfileId: carProfileId.present ? carProfileId.value : this.carProfileId,
    driveMode: driveMode ?? this.driveMode,
    passengerCount: passengerCount.present
        ? passengerCount.value
        : this.passengerCount,
    fuelLevelPercent: fuelLevelPercent.present
        ? fuelLevelPercent.value
        : this.fuelLevelPercent,
    tyreType: tyreType ?? this.tyreType,
    weatherNote: weatherNote ?? this.weatherNote,
    freeText: freeText ?? this.freeText,
  );
  RecordingMetadataData copyWithCompanion(RecordingMetadataCompanion data) {
    return RecordingMetadataData(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      carProfileId: data.carProfileId.present
          ? data.carProfileId.value
          : this.carProfileId,
      driveMode: data.driveMode.present ? data.driveMode.value : this.driveMode,
      passengerCount: data.passengerCount.present
          ? data.passengerCount.value
          : this.passengerCount,
      fuelLevelPercent: data.fuelLevelPercent.present
          ? data.fuelLevelPercent.value
          : this.fuelLevelPercent,
      tyreType: data.tyreType.present ? data.tyreType.value : this.tyreType,
      weatherNote: data.weatherNote.present
          ? data.weatherNote.value
          : this.weatherNote,
      freeText: data.freeText.present ? data.freeText.value : this.freeText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecordingMetadataData(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('carProfileId: $carProfileId, ')
          ..write('driveMode: $driveMode, ')
          ..write('passengerCount: $passengerCount, ')
          ..write('fuelLevelPercent: $fuelLevelPercent, ')
          ..write('tyreType: $tyreType, ')
          ..write('weatherNote: $weatherNote, ')
          ..write('freeText: $freeText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordingId,
    carProfileId,
    driveMode,
    passengerCount,
    fuelLevelPercent,
    tyreType,
    weatherNote,
    freeText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecordingMetadataData &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.carProfileId == this.carProfileId &&
          other.driveMode == this.driveMode &&
          other.passengerCount == this.passengerCount &&
          other.fuelLevelPercent == this.fuelLevelPercent &&
          other.tyreType == this.tyreType &&
          other.weatherNote == this.weatherNote &&
          other.freeText == this.freeText);
}

class RecordingMetadataCompanion
    extends UpdateCompanion<RecordingMetadataData> {
  final Value<int> id;
  final Value<int> recordingId;
  final Value<int?> carProfileId;
  final Value<String> driveMode;
  final Value<int?> passengerCount;
  final Value<int?> fuelLevelPercent;
  final Value<String> tyreType;
  final Value<String> weatherNote;
  final Value<String> freeText;
  const RecordingMetadataCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.carProfileId = const Value.absent(),
    this.driveMode = const Value.absent(),
    this.passengerCount = const Value.absent(),
    this.fuelLevelPercent = const Value.absent(),
    this.tyreType = const Value.absent(),
    this.weatherNote = const Value.absent(),
    this.freeText = const Value.absent(),
  });
  RecordingMetadataCompanion.insert({
    this.id = const Value.absent(),
    required int recordingId,
    this.carProfileId = const Value.absent(),
    this.driveMode = const Value.absent(),
    this.passengerCount = const Value.absent(),
    this.fuelLevelPercent = const Value.absent(),
    this.tyreType = const Value.absent(),
    this.weatherNote = const Value.absent(),
    this.freeText = const Value.absent(),
  }) : recordingId = Value(recordingId);
  static Insertable<RecordingMetadataData> custom({
    Expression<int>? id,
    Expression<int>? recordingId,
    Expression<int>? carProfileId,
    Expression<String>? driveMode,
    Expression<int>? passengerCount,
    Expression<int>? fuelLevelPercent,
    Expression<String>? tyreType,
    Expression<String>? weatherNote,
    Expression<String>? freeText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (carProfileId != null) 'car_profile_id': carProfileId,
      if (driveMode != null) 'drive_mode': driveMode,
      if (passengerCount != null) 'passenger_count': passengerCount,
      if (fuelLevelPercent != null) 'fuel_level_percent': fuelLevelPercent,
      if (tyreType != null) 'tyre_type': tyreType,
      if (weatherNote != null) 'weather_note': weatherNote,
      if (freeText != null) 'free_text': freeText,
    });
  }

  RecordingMetadataCompanion copyWith({
    Value<int>? id,
    Value<int>? recordingId,
    Value<int?>? carProfileId,
    Value<String>? driveMode,
    Value<int?>? passengerCount,
    Value<int?>? fuelLevelPercent,
    Value<String>? tyreType,
    Value<String>? weatherNote,
    Value<String>? freeText,
  }) {
    return RecordingMetadataCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      carProfileId: carProfileId ?? this.carProfileId,
      driveMode: driveMode ?? this.driveMode,
      passengerCount: passengerCount ?? this.passengerCount,
      fuelLevelPercent: fuelLevelPercent ?? this.fuelLevelPercent,
      tyreType: tyreType ?? this.tyreType,
      weatherNote: weatherNote ?? this.weatherNote,
      freeText: freeText ?? this.freeText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<int>(recordingId.value);
    }
    if (carProfileId.present) {
      map['car_profile_id'] = Variable<int>(carProfileId.value);
    }
    if (driveMode.present) {
      map['drive_mode'] = Variable<String>(driveMode.value);
    }
    if (passengerCount.present) {
      map['passenger_count'] = Variable<int>(passengerCount.value);
    }
    if (fuelLevelPercent.present) {
      map['fuel_level_percent'] = Variable<int>(fuelLevelPercent.value);
    }
    if (tyreType.present) {
      map['tyre_type'] = Variable<String>(tyreType.value);
    }
    if (weatherNote.present) {
      map['weather_note'] = Variable<String>(weatherNote.value);
    }
    if (freeText.present) {
      map['free_text'] = Variable<String>(freeText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordingMetadataCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('carProfileId: $carProfileId, ')
          ..write('driveMode: $driveMode, ')
          ..write('passengerCount: $passengerCount, ')
          ..write('fuelLevelPercent: $fuelLevelPercent, ')
          ..write('tyreType: $tyreType, ')
          ..write('weatherNote: $weatherNote, ')
          ..write('freeText: $freeText')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecordingsTable recordings = $RecordingsTable(this);
  late final $SensorSamplesTable sensorSamples = $SensorSamplesTable(this);
  late final $CarProfilesTable carProfiles = $CarProfilesTable(this);
  late final $RecordingMetadataTable recordingMetadata =
      $RecordingMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recordings,
    sensorSamples,
    carProfiles,
    recordingMetadata,
  ];
}

typedef $$RecordingsTableCreateCompanionBuilder =
    RecordingsCompanion Function({
      Value<int> id,
      required String name,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMs,
      Value<bool> isDevRecording,
      Value<String> notes,
    });
typedef $$RecordingsTableUpdateCompanionBuilder =
    RecordingsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMs,
      Value<bool> isDevRecording,
      Value<String> notes,
    });

final class $$RecordingsTableReferences
    extends BaseReferences<_$AppDatabase, $RecordingsTable, Recording> {
  $$RecordingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SensorSamplesTable, List<SensorSample>>
  _sensorSamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sensorSamples,
    aliasName: $_aliasNameGenerator(
      db.recordings.id,
      db.sensorSamples.recordingId,
    ),
  );

  $$SensorSamplesTableProcessedTableManager get sensorSamplesRefs {
    final manager = $$SensorSamplesTableTableManager(
      $_db,
      $_db.sensorSamples,
    ).filter((f) => f.recordingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sensorSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecordingMetadataTable,
    List<RecordingMetadataData>
  >
  _recordingMetadataRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recordingMetadata,
        aliasName: $_aliasNameGenerator(
          db.recordings.id,
          db.recordingMetadata.recordingId,
        ),
      );

  $$RecordingMetadataTableProcessedTableManager get recordingMetadataRefs {
    final manager = $$RecordingMetadataTableTableManager(
      $_db,
      $_db.recordingMetadata,
    ).filter((f) => f.recordingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recordingMetadataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecordingsTableFilterComposer
    extends Composer<_$AppDatabase, $RecordingsTable> {
  $$RecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDevRecording => $composableBuilder(
    column: $table.isDevRecording,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sensorSamplesRefs(
    Expression<bool> Function($$SensorSamplesTableFilterComposer f) f,
  ) {
    final $$SensorSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorSamples,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorSamplesTableFilterComposer(
            $db: $db,
            $table: $db.sensorSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recordingMetadataRefs(
    Expression<bool> Function($$RecordingMetadataTableFilterComposer f) f,
  ) {
    final $$RecordingMetadataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recordingMetadata,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingMetadataTableFilterComposer(
            $db: $db,
            $table: $db.recordingMetadata,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecordingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecordingsTable> {
  $$RecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDevRecording => $composableBuilder(
    column: $table.isDevRecording,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecordingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecordingsTable> {
  $$RecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDevRecording => $composableBuilder(
    column: $table.isDevRecording,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> sensorSamplesRefs<T extends Object>(
    Expression<T> Function($$SensorSamplesTableAnnotationComposer a) f,
  ) {
    final $$SensorSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sensorSamples,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SensorSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.sensorSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recordingMetadataRefs<T extends Object>(
    Expression<T> Function($$RecordingMetadataTableAnnotationComposer a) f,
  ) {
    final $$RecordingMetadataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recordingMetadata,
          getReferencedColumn: (t) => t.recordingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecordingMetadataTableAnnotationComposer(
                $db: $db,
                $table: $db.recordingMetadata,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecordingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecordingsTable,
          Recording,
          $$RecordingsTableFilterComposer,
          $$RecordingsTableOrderingComposer,
          $$RecordingsTableAnnotationComposer,
          $$RecordingsTableCreateCompanionBuilder,
          $$RecordingsTableUpdateCompanionBuilder,
          (Recording, $$RecordingsTableReferences),
          Recording,
          PrefetchHooks Function({
            bool sensorSamplesRefs,
            bool recordingMetadataRefs,
          })
        > {
  $$RecordingsTableTableManager(_$AppDatabase db, $RecordingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isDevRecording = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => RecordingsCompanion(
                id: id,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                isDevRecording: isDevRecording,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<bool> isDevRecording = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => RecordingsCompanion.insert(
                id: id,
                name: name,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                isDevRecording: isDevRecording,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecordingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sensorSamplesRefs = false, recordingMetadataRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sensorSamplesRefs) db.sensorSamples,
                    if (recordingMetadataRefs) db.recordingMetadata,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sensorSamplesRefs)
                        await $_getPrefetchedData<
                          Recording,
                          $RecordingsTable,
                          SensorSample
                        >(
                          currentTable: table,
                          referencedTable: $$RecordingsTableReferences
                              ._sensorSamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecordingsTableReferences(
                                db,
                                table,
                                p0,
                              ).sensorSamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recordingId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recordingMetadataRefs)
                        await $_getPrefetchedData<
                          Recording,
                          $RecordingsTable,
                          RecordingMetadataData
                        >(
                          currentTable: table,
                          referencedTable: $$RecordingsTableReferences
                              ._recordingMetadataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecordingsTableReferences(
                                db,
                                table,
                                p0,
                              ).recordingMetadataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recordingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecordingsTable,
      Recording,
      $$RecordingsTableFilterComposer,
      $$RecordingsTableOrderingComposer,
      $$RecordingsTableAnnotationComposer,
      $$RecordingsTableCreateCompanionBuilder,
      $$RecordingsTableUpdateCompanionBuilder,
      (Recording, $$RecordingsTableReferences),
      Recording,
      PrefetchHooks Function({
        bool sensorSamplesRefs,
        bool recordingMetadataRefs,
      })
    >;
typedef $$SensorSamplesTableCreateCompanionBuilder =
    SensorSamplesCompanion Function({
      Value<int> id,
      required int recordingId,
      required int timestampUs,
      Value<double?> accelX,
      Value<double?> accelY,
      Value<double?> accelZ,
      Value<double?> linearAccelX,
      Value<double?> linearAccelY,
      Value<double?> linearAccelZ,
      Value<double?> gyroX,
      Value<double?> gyroY,
      Value<double?> gyroZ,
      Value<double?> forwardAccel,
      Value<double?> lateralAccel,
      Value<double?> gpsSpeed,
      Value<double?> gpsLat,
      Value<double?> gpsLon,
      Value<double?> gpsHeading,
      Value<double?> gpsAltitude,
      Value<double?> gpsAccuracy,
      Value<double?> gpsBearing,
      Value<double?> gravX,
      Value<double?> gravY,
      Value<double?> gravZ,
      Value<double?> pressure,
      Value<double?> quatW,
      Value<double?> quatX,
      Value<double?> quatY,
      Value<double?> quatZ,
    });
typedef $$SensorSamplesTableUpdateCompanionBuilder =
    SensorSamplesCompanion Function({
      Value<int> id,
      Value<int> recordingId,
      Value<int> timestampUs,
      Value<double?> accelX,
      Value<double?> accelY,
      Value<double?> accelZ,
      Value<double?> linearAccelX,
      Value<double?> linearAccelY,
      Value<double?> linearAccelZ,
      Value<double?> gyroX,
      Value<double?> gyroY,
      Value<double?> gyroZ,
      Value<double?> forwardAccel,
      Value<double?> lateralAccel,
      Value<double?> gpsSpeed,
      Value<double?> gpsLat,
      Value<double?> gpsLon,
      Value<double?> gpsHeading,
      Value<double?> gpsAltitude,
      Value<double?> gpsAccuracy,
      Value<double?> gpsBearing,
      Value<double?> gravX,
      Value<double?> gravY,
      Value<double?> gravZ,
      Value<double?> pressure,
      Value<double?> quatW,
      Value<double?> quatX,
      Value<double?> quatY,
      Value<double?> quatZ,
    });

final class $$SensorSamplesTableReferences
    extends BaseReferences<_$AppDatabase, $SensorSamplesTable, SensorSample> {
  $$SensorSamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecordingsTable _recordingIdTable(_$AppDatabase db) =>
      db.recordings.createAlias(
        $_aliasNameGenerator(db.sensorSamples.recordingId, db.recordings.id),
      );

  $$RecordingsTableProcessedTableManager get recordingId {
    final $_column = $_itemColumn<int>('recording_id')!;

    final manager = $$RecordingsTableTableManager(
      $_db,
      $_db.recordings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SensorSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $SensorSamplesTable> {
  $$SensorSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampUs => $composableBuilder(
    column: $table.timestampUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelX => $composableBuilder(
    column: $table.accelX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelY => $composableBuilder(
    column: $table.accelY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelZ => $composableBuilder(
    column: $table.accelZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get linearAccelX => $composableBuilder(
    column: $table.linearAccelX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get linearAccelY => $composableBuilder(
    column: $table.linearAccelY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get linearAccelZ => $composableBuilder(
    column: $table.linearAccelZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroX => $composableBuilder(
    column: $table.gyroX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroY => $composableBuilder(
    column: $table.gyroY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroZ => $composableBuilder(
    column: $table.gyroZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get forwardAccel => $composableBuilder(
    column: $table.forwardAccel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lateralAccel => $composableBuilder(
    column: $table.lateralAccel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsSpeed => $composableBuilder(
    column: $table.gpsSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsLat => $composableBuilder(
    column: $table.gpsLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsLon => $composableBuilder(
    column: $table.gpsLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsHeading => $composableBuilder(
    column: $table.gpsHeading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsBearing => $composableBuilder(
    column: $table.gpsBearing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gravX => $composableBuilder(
    column: $table.gravX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gravY => $composableBuilder(
    column: $table.gravY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gravZ => $composableBuilder(
    column: $table.gravZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatW => $composableBuilder(
    column: $table.quatW,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatX => $composableBuilder(
    column: $table.quatX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatY => $composableBuilder(
    column: $table.quatY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quatZ => $composableBuilder(
    column: $table.quatZ,
    builder: (column) => ColumnFilters(column),
  );

  $$RecordingsTableFilterComposer get recordingId {
    final $$RecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableFilterComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorSamplesTable> {
  $$SensorSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampUs => $composableBuilder(
    column: $table.timestampUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelX => $composableBuilder(
    column: $table.accelX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelY => $composableBuilder(
    column: $table.accelY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelZ => $composableBuilder(
    column: $table.accelZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get linearAccelX => $composableBuilder(
    column: $table.linearAccelX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get linearAccelY => $composableBuilder(
    column: $table.linearAccelY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get linearAccelZ => $composableBuilder(
    column: $table.linearAccelZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroX => $composableBuilder(
    column: $table.gyroX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroY => $composableBuilder(
    column: $table.gyroY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroZ => $composableBuilder(
    column: $table.gyroZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get forwardAccel => $composableBuilder(
    column: $table.forwardAccel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lateralAccel => $composableBuilder(
    column: $table.lateralAccel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsSpeed => $composableBuilder(
    column: $table.gpsSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsLat => $composableBuilder(
    column: $table.gpsLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsLon => $composableBuilder(
    column: $table.gpsLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsHeading => $composableBuilder(
    column: $table.gpsHeading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsBearing => $composableBuilder(
    column: $table.gpsBearing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gravX => $composableBuilder(
    column: $table.gravX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gravY => $composableBuilder(
    column: $table.gravY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gravZ => $composableBuilder(
    column: $table.gravZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pressure => $composableBuilder(
    column: $table.pressure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatW => $composableBuilder(
    column: $table.quatW,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatX => $composableBuilder(
    column: $table.quatX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatY => $composableBuilder(
    column: $table.quatY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quatZ => $composableBuilder(
    column: $table.quatZ,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecordingsTableOrderingComposer get recordingId {
    final $$RecordingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableOrderingComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorSamplesTable> {
  $$SensorSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestampUs => $composableBuilder(
    column: $table.timestampUs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelX =>
      $composableBuilder(column: $table.accelX, builder: (column) => column);

  GeneratedColumn<double> get accelY =>
      $composableBuilder(column: $table.accelY, builder: (column) => column);

  GeneratedColumn<double> get accelZ =>
      $composableBuilder(column: $table.accelZ, builder: (column) => column);

  GeneratedColumn<double> get linearAccelX => $composableBuilder(
    column: $table.linearAccelX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get linearAccelY => $composableBuilder(
    column: $table.linearAccelY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get linearAccelZ => $composableBuilder(
    column: $table.linearAccelZ,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gyroX =>
      $composableBuilder(column: $table.gyroX, builder: (column) => column);

  GeneratedColumn<double> get gyroY =>
      $composableBuilder(column: $table.gyroY, builder: (column) => column);

  GeneratedColumn<double> get gyroZ =>
      $composableBuilder(column: $table.gyroZ, builder: (column) => column);

  GeneratedColumn<double> get forwardAccel => $composableBuilder(
    column: $table.forwardAccel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lateralAccel => $composableBuilder(
    column: $table.lateralAccel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsSpeed =>
      $composableBuilder(column: $table.gpsSpeed, builder: (column) => column);

  GeneratedColumn<double> get gpsLat =>
      $composableBuilder(column: $table.gpsLat, builder: (column) => column);

  GeneratedColumn<double> get gpsLon =>
      $composableBuilder(column: $table.gpsLon, builder: (column) => column);

  GeneratedColumn<double> get gpsHeading => $composableBuilder(
    column: $table.gpsHeading,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsAltitude => $composableBuilder(
    column: $table.gpsAltitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsBearing => $composableBuilder(
    column: $table.gpsBearing,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gravX =>
      $composableBuilder(column: $table.gravX, builder: (column) => column);

  GeneratedColumn<double> get gravY =>
      $composableBuilder(column: $table.gravY, builder: (column) => column);

  GeneratedColumn<double> get gravZ =>
      $composableBuilder(column: $table.gravZ, builder: (column) => column);

  GeneratedColumn<double> get pressure =>
      $composableBuilder(column: $table.pressure, builder: (column) => column);

  GeneratedColumn<double> get quatW =>
      $composableBuilder(column: $table.quatW, builder: (column) => column);

  GeneratedColumn<double> get quatX =>
      $composableBuilder(column: $table.quatX, builder: (column) => column);

  GeneratedColumn<double> get quatY =>
      $composableBuilder(column: $table.quatY, builder: (column) => column);

  GeneratedColumn<double> get quatZ =>
      $composableBuilder(column: $table.quatZ, builder: (column) => column);

  $$RecordingsTableAnnotationComposer get recordingId {
    final $$RecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SensorSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorSamplesTable,
          SensorSample,
          $$SensorSamplesTableFilterComposer,
          $$SensorSamplesTableOrderingComposer,
          $$SensorSamplesTableAnnotationComposer,
          $$SensorSamplesTableCreateCompanionBuilder,
          $$SensorSamplesTableUpdateCompanionBuilder,
          (SensorSample, $$SensorSamplesTableReferences),
          SensorSample,
          PrefetchHooks Function({bool recordingId})
        > {
  $$SensorSamplesTableTableManager(_$AppDatabase db, $SensorSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recordingId = const Value.absent(),
                Value<int> timestampUs = const Value.absent(),
                Value<double?> accelX = const Value.absent(),
                Value<double?> accelY = const Value.absent(),
                Value<double?> accelZ = const Value.absent(),
                Value<double?> linearAccelX = const Value.absent(),
                Value<double?> linearAccelY = const Value.absent(),
                Value<double?> linearAccelZ = const Value.absent(),
                Value<double?> gyroX = const Value.absent(),
                Value<double?> gyroY = const Value.absent(),
                Value<double?> gyroZ = const Value.absent(),
                Value<double?> forwardAccel = const Value.absent(),
                Value<double?> lateralAccel = const Value.absent(),
                Value<double?> gpsSpeed = const Value.absent(),
                Value<double?> gpsLat = const Value.absent(),
                Value<double?> gpsLon = const Value.absent(),
                Value<double?> gpsHeading = const Value.absent(),
                Value<double?> gpsAltitude = const Value.absent(),
                Value<double?> gpsAccuracy = const Value.absent(),
                Value<double?> gpsBearing = const Value.absent(),
                Value<double?> gravX = const Value.absent(),
                Value<double?> gravY = const Value.absent(),
                Value<double?> gravZ = const Value.absent(),
                Value<double?> pressure = const Value.absent(),
                Value<double?> quatW = const Value.absent(),
                Value<double?> quatX = const Value.absent(),
                Value<double?> quatY = const Value.absent(),
                Value<double?> quatZ = const Value.absent(),
              }) => SensorSamplesCompanion(
                id: id,
                recordingId: recordingId,
                timestampUs: timestampUs,
                accelX: accelX,
                accelY: accelY,
                accelZ: accelZ,
                linearAccelX: linearAccelX,
                linearAccelY: linearAccelY,
                linearAccelZ: linearAccelZ,
                gyroX: gyroX,
                gyroY: gyroY,
                gyroZ: gyroZ,
                forwardAccel: forwardAccel,
                lateralAccel: lateralAccel,
                gpsSpeed: gpsSpeed,
                gpsLat: gpsLat,
                gpsLon: gpsLon,
                gpsHeading: gpsHeading,
                gpsAltitude: gpsAltitude,
                gpsAccuracy: gpsAccuracy,
                gpsBearing: gpsBearing,
                gravX: gravX,
                gravY: gravY,
                gravZ: gravZ,
                pressure: pressure,
                quatW: quatW,
                quatX: quatX,
                quatY: quatY,
                quatZ: quatZ,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recordingId,
                required int timestampUs,
                Value<double?> accelX = const Value.absent(),
                Value<double?> accelY = const Value.absent(),
                Value<double?> accelZ = const Value.absent(),
                Value<double?> linearAccelX = const Value.absent(),
                Value<double?> linearAccelY = const Value.absent(),
                Value<double?> linearAccelZ = const Value.absent(),
                Value<double?> gyroX = const Value.absent(),
                Value<double?> gyroY = const Value.absent(),
                Value<double?> gyroZ = const Value.absent(),
                Value<double?> forwardAccel = const Value.absent(),
                Value<double?> lateralAccel = const Value.absent(),
                Value<double?> gpsSpeed = const Value.absent(),
                Value<double?> gpsLat = const Value.absent(),
                Value<double?> gpsLon = const Value.absent(),
                Value<double?> gpsHeading = const Value.absent(),
                Value<double?> gpsAltitude = const Value.absent(),
                Value<double?> gpsAccuracy = const Value.absent(),
                Value<double?> gpsBearing = const Value.absent(),
                Value<double?> gravX = const Value.absent(),
                Value<double?> gravY = const Value.absent(),
                Value<double?> gravZ = const Value.absent(),
                Value<double?> pressure = const Value.absent(),
                Value<double?> quatW = const Value.absent(),
                Value<double?> quatX = const Value.absent(),
                Value<double?> quatY = const Value.absent(),
                Value<double?> quatZ = const Value.absent(),
              }) => SensorSamplesCompanion.insert(
                id: id,
                recordingId: recordingId,
                timestampUs: timestampUs,
                accelX: accelX,
                accelY: accelY,
                accelZ: accelZ,
                linearAccelX: linearAccelX,
                linearAccelY: linearAccelY,
                linearAccelZ: linearAccelZ,
                gyroX: gyroX,
                gyroY: gyroY,
                gyroZ: gyroZ,
                forwardAccel: forwardAccel,
                lateralAccel: lateralAccel,
                gpsSpeed: gpsSpeed,
                gpsLat: gpsLat,
                gpsLon: gpsLon,
                gpsHeading: gpsHeading,
                gpsAltitude: gpsAltitude,
                gpsAccuracy: gpsAccuracy,
                gpsBearing: gpsBearing,
                gravX: gravX,
                gravY: gravY,
                gravZ: gravZ,
                pressure: pressure,
                quatW: quatW,
                quatX: quatX,
                quatY: quatY,
                quatZ: quatZ,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SensorSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recordingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recordingId,
                                referencedTable: $$SensorSamplesTableReferences
                                    ._recordingIdTable(db),
                                referencedColumn: $$SensorSamplesTableReferences
                                    ._recordingIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SensorSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorSamplesTable,
      SensorSample,
      $$SensorSamplesTableFilterComposer,
      $$SensorSamplesTableOrderingComposer,
      $$SensorSamplesTableAnnotationComposer,
      $$SensorSamplesTableCreateCompanionBuilder,
      $$SensorSamplesTableUpdateCompanionBuilder,
      (SensorSample, $$SensorSamplesTableReferences),
      SensorSample,
      PrefetchHooks Function({bool recordingId})
    >;
typedef $$CarProfilesTableCreateCompanionBuilder =
    CarProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> make,
      Value<String> model,
      Value<int?> year,
      Value<String> fuelType,
      Value<String> transmission,
    });
typedef $$CarProfilesTableUpdateCompanionBuilder =
    CarProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> make,
      Value<String> model,
      Value<int?> year,
      Value<String> fuelType,
      Value<String> transmission,
    });

final class $$CarProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $CarProfilesTable, CarProfile> {
  $$CarProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RecordingMetadataTable,
    List<RecordingMetadataData>
  >
  _recordingMetadataRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recordingMetadata,
        aliasName: $_aliasNameGenerator(
          db.carProfiles.id,
          db.recordingMetadata.carProfileId,
        ),
      );

  $$RecordingMetadataTableProcessedTableManager get recordingMetadataRefs {
    final manager = $$RecordingMetadataTableTableManager(
      $_db,
      $_db.recordingMetadata,
    ).filter((f) => f.carProfileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recordingMetadataRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CarProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CarProfilesTable> {
  $$CarProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recordingMetadataRefs(
    Expression<bool> Function($$RecordingMetadataTableFilterComposer f) f,
  ) {
    final $$RecordingMetadataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recordingMetadata,
      getReferencedColumn: (t) => t.carProfileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingMetadataTableFilterComposer(
            $db: $db,
            $table: $db.recordingMetadata,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CarProfilesTable> {
  $$CarProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CarProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarProfilesTable> {
  $$CarProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<String> get transmission => $composableBuilder(
    column: $table.transmission,
    builder: (column) => column,
  );

  Expression<T> recordingMetadataRefs<T extends Object>(
    Expression<T> Function($$RecordingMetadataTableAnnotationComposer a) f,
  ) {
    final $$RecordingMetadataTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recordingMetadata,
          getReferencedColumn: (t) => t.carProfileId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecordingMetadataTableAnnotationComposer(
                $db: $db,
                $table: $db.recordingMetadata,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CarProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarProfilesTable,
          CarProfile,
          $$CarProfilesTableFilterComposer,
          $$CarProfilesTableOrderingComposer,
          $$CarProfilesTableAnnotationComposer,
          $$CarProfilesTableCreateCompanionBuilder,
          $$CarProfilesTableUpdateCompanionBuilder,
          (CarProfile, $$CarProfilesTableReferences),
          CarProfile,
          PrefetchHooks Function({bool recordingMetadataRefs})
        > {
  $$CarProfilesTableTableManager(_$AppDatabase db, $CarProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<String> transmission = const Value.absent(),
              }) => CarProfilesCompanion(
                id: id,
                name: name,
                make: make,
                model: model,
                year: year,
                fuelType: fuelType,
                transmission: transmission,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<String> transmission = const Value.absent(),
              }) => CarProfilesCompanion.insert(
                id: id,
                name: name,
                make: make,
                model: model,
                year: year,
                fuelType: fuelType,
                transmission: transmission,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CarProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordingMetadataRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recordingMetadataRefs) db.recordingMetadata,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recordingMetadataRefs)
                    await $_getPrefetchedData<
                      CarProfile,
                      $CarProfilesTable,
                      RecordingMetadataData
                    >(
                      currentTable: table,
                      referencedTable: $$CarProfilesTableReferences
                          ._recordingMetadataRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CarProfilesTableReferences(
                            db,
                            table,
                            p0,
                          ).recordingMetadataRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.carProfileId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CarProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarProfilesTable,
      CarProfile,
      $$CarProfilesTableFilterComposer,
      $$CarProfilesTableOrderingComposer,
      $$CarProfilesTableAnnotationComposer,
      $$CarProfilesTableCreateCompanionBuilder,
      $$CarProfilesTableUpdateCompanionBuilder,
      (CarProfile, $$CarProfilesTableReferences),
      CarProfile,
      PrefetchHooks Function({bool recordingMetadataRefs})
    >;
typedef $$RecordingMetadataTableCreateCompanionBuilder =
    RecordingMetadataCompanion Function({
      Value<int> id,
      required int recordingId,
      Value<int?> carProfileId,
      Value<String> driveMode,
      Value<int?> passengerCount,
      Value<int?> fuelLevelPercent,
      Value<String> tyreType,
      Value<String> weatherNote,
      Value<String> freeText,
    });
typedef $$RecordingMetadataTableUpdateCompanionBuilder =
    RecordingMetadataCompanion Function({
      Value<int> id,
      Value<int> recordingId,
      Value<int?> carProfileId,
      Value<String> driveMode,
      Value<int?> passengerCount,
      Value<int?> fuelLevelPercent,
      Value<String> tyreType,
      Value<String> weatherNote,
      Value<String> freeText,
    });

final class $$RecordingMetadataTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecordingMetadataTable,
          RecordingMetadataData
        > {
  $$RecordingMetadataTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecordingsTable _recordingIdTable(_$AppDatabase db) =>
      db.recordings.createAlias(
        $_aliasNameGenerator(
          db.recordingMetadata.recordingId,
          db.recordings.id,
        ),
      );

  $$RecordingsTableProcessedTableManager get recordingId {
    final $_column = $_itemColumn<int>('recording_id')!;

    final manager = $$RecordingsTableTableManager(
      $_db,
      $_db.recordings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CarProfilesTable _carProfileIdTable(_$AppDatabase db) =>
      db.carProfiles.createAlias(
        $_aliasNameGenerator(
          db.recordingMetadata.carProfileId,
          db.carProfiles.id,
        ),
      );

  $$CarProfilesTableProcessedTableManager? get carProfileId {
    final $_column = $_itemColumn<int>('car_profile_id');
    if ($_column == null) return null;
    final manager = $$CarProfilesTableTableManager(
      $_db,
      $_db.carProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carProfileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecordingMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $RecordingMetadataTable> {
  $$RecordingMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get driveMode => $composableBuilder(
    column: $table.driveMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passengerCount => $composableBuilder(
    column: $table.passengerCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fuelLevelPercent => $composableBuilder(
    column: $table.fuelLevelPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tyreType => $composableBuilder(
    column: $table.tyreType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherNote => $composableBuilder(
    column: $table.weatherNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeText => $composableBuilder(
    column: $table.freeText,
    builder: (column) => ColumnFilters(column),
  );

  $$RecordingsTableFilterComposer get recordingId {
    final $$RecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableFilterComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CarProfilesTableFilterComposer get carProfileId {
    final $$CarProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carProfileId,
      referencedTable: $db.carProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarProfilesTableFilterComposer(
            $db: $db,
            $table: $db.carProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordingMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $RecordingMetadataTable> {
  $$RecordingMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get driveMode => $composableBuilder(
    column: $table.driveMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passengerCount => $composableBuilder(
    column: $table.passengerCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fuelLevelPercent => $composableBuilder(
    column: $table.fuelLevelPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tyreType => $composableBuilder(
    column: $table.tyreType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherNote => $composableBuilder(
    column: $table.weatherNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeText => $composableBuilder(
    column: $table.freeText,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecordingsTableOrderingComposer get recordingId {
    final $$RecordingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableOrderingComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CarProfilesTableOrderingComposer get carProfileId {
    final $$CarProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carProfileId,
      referencedTable: $db.carProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.carProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordingMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecordingMetadataTable> {
  $$RecordingMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get driveMode =>
      $composableBuilder(column: $table.driveMode, builder: (column) => column);

  GeneratedColumn<int> get passengerCount => $composableBuilder(
    column: $table.passengerCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fuelLevelPercent => $composableBuilder(
    column: $table.fuelLevelPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tyreType =>
      $composableBuilder(column: $table.tyreType, builder: (column) => column);

  GeneratedColumn<String> get weatherNote => $composableBuilder(
    column: $table.weatherNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freeText =>
      $composableBuilder(column: $table.freeText, builder: (column) => column);

  $$RecordingsTableAnnotationComposer get recordingId {
    final $$RecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CarProfilesTableAnnotationComposer get carProfileId {
    final $$CarProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carProfileId,
      referencedTable: $db.carProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.carProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordingMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecordingMetadataTable,
          RecordingMetadataData,
          $$RecordingMetadataTableFilterComposer,
          $$RecordingMetadataTableOrderingComposer,
          $$RecordingMetadataTableAnnotationComposer,
          $$RecordingMetadataTableCreateCompanionBuilder,
          $$RecordingMetadataTableUpdateCompanionBuilder,
          (RecordingMetadataData, $$RecordingMetadataTableReferences),
          RecordingMetadataData,
          PrefetchHooks Function({bool recordingId, bool carProfileId})
        > {
  $$RecordingMetadataTableTableManager(
    _$AppDatabase db,
    $RecordingMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordingMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordingMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordingMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recordingId = const Value.absent(),
                Value<int?> carProfileId = const Value.absent(),
                Value<String> driveMode = const Value.absent(),
                Value<int?> passengerCount = const Value.absent(),
                Value<int?> fuelLevelPercent = const Value.absent(),
                Value<String> tyreType = const Value.absent(),
                Value<String> weatherNote = const Value.absent(),
                Value<String> freeText = const Value.absent(),
              }) => RecordingMetadataCompanion(
                id: id,
                recordingId: recordingId,
                carProfileId: carProfileId,
                driveMode: driveMode,
                passengerCount: passengerCount,
                fuelLevelPercent: fuelLevelPercent,
                tyreType: tyreType,
                weatherNote: weatherNote,
                freeText: freeText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recordingId,
                Value<int?> carProfileId = const Value.absent(),
                Value<String> driveMode = const Value.absent(),
                Value<int?> passengerCount = const Value.absent(),
                Value<int?> fuelLevelPercent = const Value.absent(),
                Value<String> tyreType = const Value.absent(),
                Value<String> weatherNote = const Value.absent(),
                Value<String> freeText = const Value.absent(),
              }) => RecordingMetadataCompanion.insert(
                id: id,
                recordingId: recordingId,
                carProfileId: carProfileId,
                driveMode: driveMode,
                passengerCount: passengerCount,
                fuelLevelPercent: fuelLevelPercent,
                tyreType: tyreType,
                weatherNote: weatherNote,
                freeText: freeText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecordingMetadataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordingId = false, carProfileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recordingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recordingId,
                                referencedTable:
                                    $$RecordingMetadataTableReferences
                                        ._recordingIdTable(db),
                                referencedColumn:
                                    $$RecordingMetadataTableReferences
                                        ._recordingIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (carProfileId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.carProfileId,
                                referencedTable:
                                    $$RecordingMetadataTableReferences
                                        ._carProfileIdTable(db),
                                referencedColumn:
                                    $$RecordingMetadataTableReferences
                                        ._carProfileIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecordingMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecordingMetadataTable,
      RecordingMetadataData,
      $$RecordingMetadataTableFilterComposer,
      $$RecordingMetadataTableOrderingComposer,
      $$RecordingMetadataTableAnnotationComposer,
      $$RecordingMetadataTableCreateCompanionBuilder,
      $$RecordingMetadataTableUpdateCompanionBuilder,
      (RecordingMetadataData, $$RecordingMetadataTableReferences),
      RecordingMetadataData,
      PrefetchHooks Function({bool recordingId, bool carProfileId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecordingsTableTableManager get recordings =>
      $$RecordingsTableTableManager(_db, _db.recordings);
  $$SensorSamplesTableTableManager get sensorSamples =>
      $$SensorSamplesTableTableManager(_db, _db.sensorSamples);
  $$CarProfilesTableTableManager get carProfiles =>
      $$CarProfilesTableTableManager(_db, _db.carProfiles);
  $$RecordingMetadataTableTableManager get recordingMetadata =>
      $$RecordingMetadataTableTableManager(_db, _db.recordingMetadata);
}
