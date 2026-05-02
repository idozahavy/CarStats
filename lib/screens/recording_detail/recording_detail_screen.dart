import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/chart_utils.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../services/export_service.dart';
import 'metadata_sheet.dart';

enum _ExportAction { saveCsv, saveJson, shareCsv, shareJson }

class RecordingDetailScreen extends StatefulWidget {
  final int recordingId;
  const RecordingDetailScreen({super.key, required this.recordingId});

  @override
  State<RecordingDetailScreen> createState() => _RecordingDetailScreenState();
}

class _RecordingDetailScreenState extends State<RecordingDetailScreen> {
  late final RecordingStore _db;
  Recording? _recording;
  List<SensorSample> _samples = [];
  RecordingMetadataData? _metadata;
  CarProfile? _car;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _db = context.read<RecordingStore>();
    _load();
  }

  Future<void> _load() async {
    final rec = await _db.getRecording(widget.recordingId);
    final samples = await _db.getSamplesForRecording(widget.recordingId);
    final metadata = await _db.getMetadataForRecording(widget.recordingId);
    final car = metadata?.carProfileId == null
        ? null
        : await _db.getCarProfile(metadata!.carProfileId!);
    if (!mounted) return;
    setState(() {
      _recording = rec;
      _samples = samples;
      _metadata = metadata;
      _car = car;
      _loading = false;
    });
  }

  Future<void> _editMetadata() async {
    final saved = await showMetadataSheet(
      context,
      recordingId: widget.recordingId,
      initial: _metadata,
    );
    if (saved == true) await _reloadMetadata();
  }

  Future<void> _reloadMetadata() async {
    final metadata = await _db.getMetadataForRecording(widget.recordingId);
    final car = metadata?.carProfileId == null
        ? null
        : await _db.getCarProfile(metadata!.carProfileId!);
    if (!mounted) return;
    setState(() {
      _metadata = metadata;
      _car = car;
    });
  }

  Future<void> _runExportAction(
    BuildContext context,
    _ExportAction action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    final format = switch (action) {
      _ExportAction.saveCsv || _ExportAction.shareCsv => ExportFormat.csv,
      _ExportAction.saveJson || _ExportAction.shareJson => ExportFormat.json,
    };
    final isShare =
        action == _ExportAction.shareCsv || action == _ExportAction.shareJson;

    try {
      if (isShare) {
        await ExportService.shareRecording(
          _recording!,
          _samples,
          format,
          metadata: _metadata,
          carProfile: _car,
        );
        return;
      }
      final file = await ExportService.exportRecording(
        _recording!,
        _samples,
        format,
        metadata: _metadata,
        carProfile: _car,
      );
      if (file == null) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.detail_export_saved_to(file.path))),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isShare
                ? l.detail_share_failed(e.toString())
                : l.detail_export_failed(e.toString()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_recording?.name ?? l.detail_default_title),
        actions: [
          if (_recording != null && _samples.isNotEmpty)
            PopupMenuButton<_ExportAction>(
              icon: const Icon(Icons.file_download),
              tooltip: l.detail_export_tooltip,
              onSelected: (action) => _runExportAction(context, action),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _ExportAction.saveCsv,
                  child: Text(l.detail_export_save_csv),
                ),
                PopupMenuItem(
                  value: _ExportAction.saveJson,
                  child: Text(l.detail_export_save_json),
                ),
                PopupMenuItem(
                  value: _ExportAction.shareCsv,
                  child: Text(l.detail_export_share_csv),
                ),
                PopupMenuItem(
                  value: _ExportAction.shareJson,
                  child: Text(l.detail_export_share_json),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _samples.isEmpty
            ? Center(
                child: Text(
                  l.detail_empty,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetadataSection(
                      metadata: _metadata,
                      car: _car,
                      onEdit: _editMetadata,
                    ),
                    const SizedBox(height: 16),
                    _SummaryCards(recording: _recording!, samples: _samples),
                    const SizedBox(height: 24),
                    Text(
                      l.detail_chart_speed_vs_accel,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: _SpeedAccelChart(samples: _samples),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l.detail_chart_accel_time,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: _AccelTimeChart(samples: _samples),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l.detail_chart_speed_time,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: _SpeedTimeChart(samples: _samples),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MetadataSection extends StatelessWidget {
  final RecordingMetadataData? metadata;
  final CarProfile? car;
  final VoidCallback onEdit;

  const _MetadataSection({
    required this.metadata,
    required this.car,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (metadata == null) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.add),
          label: Text(l.detail_metadata_add_button),
        ),
      );
    }
    final m = metadata!;
    final theme = Theme.of(context);
    final lines = <String>[
      '${l.detail_metadata_summary_car}: ${car?.name ?? l.detail_metadata_summary_no_car}',
      if (m.driveMode.isNotEmpty)
        '${l.detail_metadata_summary_drive_mode}: ${m.driveMode}',
      if (m.passengerCount != null)
        '${l.detail_metadata_summary_passengers}: ${m.passengerCount}',
      if (m.fuelLevelPercent != null)
        '${l.detail_metadata_summary_fuel_level}: ${m.fuelLevelPercent}%',
      if (m.tyreType.isNotEmpty)
        '${l.detail_metadata_summary_tyres}: ${m.tyreType}',
      if (m.weatherNote.isNotEmpty)
        '${l.detail_metadata_summary_weather}: ${m.weatherNote}',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        line,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: Text(l.detail_metadata_edit_button),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Recording recording;
  final List<SensorSample> samples;

  const _SummaryCards({required this.recording, required this.samples});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    double maxSpeed = 0;
    double maxAccel = 0;
    double minAccel = 0;

    for (final s in samples) {
      final speed = (s.gpsSpeed ?? 0) * 3.6;
      if (speed > maxSpeed) maxSpeed = speed;
      final accel = (s.forwardAccel ?? 0) / 9.81;
      if (accel > maxAccel) maxAccel = accel;
      if (accel < minAccel) minAccel = accel;
    }

    final duration = Duration(milliseconds: recording.durationMs);
    final durationStr =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(
          child: _MiniCard(label: l.detail_summary_duration, value: durationStr),
        ),
        Expanded(
          child: _MiniCard(
            label: l.detail_summary_max_speed,
            value: '${maxSpeed.toStringAsFixed(1)} km/h',
          ),
        ),
        Expanded(
          child: _MiniCard(
            label: l.detail_summary_max_accel,
            value: '${maxAccel.toStringAsFixed(2)} g',
          ),
        ),
        Expanded(
          child: _MiniCard(
            label: l.detail_summary_max_brake,
            value: '${minAccel.toStringAsFixed(2)} g',
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final String value;
  const _MiniCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedAccelChart extends StatelessWidget {
  final List<SensorSample> samples;
  const _SpeedAccelChart({required this.samples});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final spots = <FlSpot>[];
    for (final s in samples) {
      if (s.gpsSpeed != null && s.forwardAccel != null) {
        spots.add(FlSpot(s.gpsSpeed! * 3.6, s.forwardAccel! / 9.81));
      }
    }
    if (spots.isEmpty) return Center(child: Text(l.detail_chart_no_gps_accel));

    final displaySpots = downsample(spots);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_speed_kmh,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_accel_g,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: displaySpots,
            isCurved: false,
            color: theme.colorScheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _AccelTimeChart extends StatelessWidget {
  final List<SensorSample> samples;
  const _AccelTimeChart({required this.samples});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final spots = <FlSpot>[];
    for (final s in samples) {
      if (s.forwardAccel != null) {
        spots.add(FlSpot(s.timestampUs / 1e6, s.forwardAccel! / 9.81));
      }
    }
    if (spots.isEmpty) return Center(child: Text(l.detail_chart_no_accel));

    final displaySpots = downsample(spots);
    final maxTime = spots.last.x;
    final interval = _timeInterval(maxTime);
    return LineChart(
      LineChartData(
        minY: -1.5,
        maxY: 1.5,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_time_s,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_accel_g,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: displaySpots,
            isCurved: false,
            color: theme.colorScheme.tertiary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _SpeedTimeChart extends StatelessWidget {
  final List<SensorSample> samples;
  const _SpeedTimeChart({required this.samples});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final spots = <FlSpot>[];
    for (final s in samples) {
      if (s.gpsSpeed != null) {
        spots.add(FlSpot(s.timestampUs / 1e6, s.gpsSpeed! * 3.6));
      }
    }
    if (spots.isEmpty) return Center(child: Text(l.detail_chart_no_speed));

    final displaySpots = downsample(spots);
    final maxTime = spots.last.x;
    final interval = _timeInterval(maxTime);
    double maxObservedSpeed = 0;
    for (final spot in spots) {
      if (spot.y > maxObservedSpeed) maxObservedSpeed = spot.y;
    }
    final maxY = ((maxObservedSpeed / 50).ceil() * 50)
        .toDouble()
        .clamp(50.0, 400.0);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_time_s,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_kmh,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: displaySpots,
            isCurved: false,
            color: theme.colorScheme.secondary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

double _timeInterval(double maxSeconds) {
  if (maxSeconds <= 30) return 5;
  if (maxSeconds <= 60) return 10;
  if (maxSeconds <= 180) return 30;
  if (maxSeconds <= 600) return 60;
  return 120;
}
