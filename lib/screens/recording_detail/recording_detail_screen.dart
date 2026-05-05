import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/chart_utils.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../services/benchmarks/benchmarks.dart';
import '../../services/data_quality.dart';
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
                    const SizedBox(height: 16),
                    _DataQualityBadge(
                      quality: computeDataQuality(
                        _samples,
                        _recording!.durationMs,
                      ),
                    ),
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
                    const SizedBox(height: 24),
                    _BenchmarksSection(
                      report: computeBenchmarks(_samples),
                      isDevRecording: _recording!.isDevRecording,
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

class _DataQualityBadge extends StatelessWidget {
  final DataQuality quality;
  const _DataQualityBadge({required this.quality});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.detail_quality_title,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QualityChip(
                  label: l.detail_quality_sample_rate,
                  value: '${quality.sampleRateHz.toStringAsFixed(0)} Hz',
                  grade: quality.sampleRateGrade,
                  tooltip: l.detail_quality_tooltip(
                    '${DataQualityThresholds.sampleRateGreenHz.toStringAsFixed(0)} Hz',
                    '${DataQualityThresholds.sampleRateAmberHz.toStringAsFixed(0)} Hz',
                  ),
                ),
                _QualityChip(
                  label: l.detail_quality_gps_coverage,
                  value: '${quality.gpsCoveragePercent.toStringAsFixed(0)}%',
                  grade: quality.gpsCoverageGrade,
                  tooltip: l.detail_quality_tooltip(
                    '${DataQualityThresholds.gpsCoverageGreenPercent.toStringAsFixed(0)}%',
                    '${DataQualityThresholds.gpsCoverageAmberPercent.toStringAsFixed(0)}%',
                  ),
                ),
                _QualityChip(
                  label: l.detail_quality_heading_lock,
                  value:
                      '${quality.headingLockedPercent.toStringAsFixed(0)}%',
                  grade: quality.headingLockedGrade,
                  tooltip: l.detail_quality_tooltip(
                    '${DataQualityThresholds.headingLockedGreenPercent.toStringAsFixed(0)}%',
                    '${DataQualityThresholds.headingLockedAmberPercent.toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BenchmarksSection extends StatelessWidget {
  final BenchmarkReport report;
  final bool isDevRecording;

  const _BenchmarksSection({
    required this.report,
    required this.isDevRecording,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.detail_benchmarks_title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (isDevRecording) ...[
          MaterialBanner(
            content: Text(l.detail_benchmarks_dev_banner),
            backgroundColor: theme.colorScheme.tertiaryContainer,
            actions: const [SizedBox.shrink()],
            forceActionsBelow: true,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          l.detail_benchmarks_standard_section,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _StandardBenchmarksGrid(items: report.standard),
        const SizedBox(height: 16),
        Text(
          l.detail_benchmarks_max_accel_section,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _MaxAccelBucketsList(items: report.maxAccelByBucket),
        const SizedBox(height: 16),
        Text(
          l.detail_benchmarks_sudden_section,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _SuddenAccelList(items: report.suddenAccelEvents),
      ],
    );
  }
}

class _StandardBenchmarksGrid extends StatelessWidget {
  final List<StandardBenchmark> items;
  const _StandardBenchmarksGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items) _StandardBenchmarkCard(item: item, l: l),
      ],
    );
  }
}

class _StandardBenchmarkCard extends StatelessWidget {
  final StandardBenchmark item;
  final AppLocalizations l;
  const _StandardBenchmarkCard({required this.item, required this.l});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = item.time;
    final String value;
    if (time == null) {
      value = l.detail_benchmarks_unavailable;
    } else if (item.trapSpeedKmh != null) {
      value = l.detail_benchmarks_quarter_mile_trap(
        _formatSeconds(time),
        item.trapSpeedKmh!.toStringAsFixed(0),
      );
    } else {
      value = l.detail_benchmarks_seconds(_formatSeconds(time));
    }
    final card = SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (item.unavailableReason == null) return card;
    return Tooltip(message: item.unavailableReason!, child: card);
  }
}

String _formatSeconds(Duration d) {
  final s = d.inMicroseconds / 1e6;
  return s.toStringAsFixed(2);
}

class _MaxAccelBucketsList extends StatelessWidget {
  final List<MaxAccelAtSpeed> items;
  const _MaxAccelBucketsList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final hasAny = items.any((b) => b.peakG != null);
    if (!hasAny) {
      return Text(
        l.detail_benchmarks_no_max_accel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            for (final b in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        l.detail_benchmarks_bucket_label(
                          b.speedBucketKmh.toString(),
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        b.peakG == null
                            ? l.detail_benchmarks_unavailable
                            : l.detail_benchmarks_bucket_g(
                                b.peakG!.toStringAsFixed(2),
                              ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuddenAccelList extends StatelessWidget {
  final List<SuddenAccelEvent> items;
  const _SuddenAccelList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return Text(
        l.detail_benchmarks_no_sudden,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final e in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l.detail_benchmarks_sudden_event(
                    e.cruiseSpeedKmh.toStringAsFixed(0),
                    e.peakG.toStringAsFixed(2),
                    e.responseTime.inMilliseconds.toString(),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  final String label;
  final String value;
  final QualityGrade grade;
  final String tooltip;

  const _QualityChip({
    required this.label,
    required this.value,
    required this.grade,
    required this.tooltip,
  });

  Color _bg(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (grade) {
      case QualityGrade.green:
        return scheme.primaryContainer;
      case QualityGrade.amber:
        return scheme.tertiaryContainer;
      case QualityGrade.red:
        return scheme.errorContainer;
    }
  }

  Color _fg(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (grade) {
      case QualityGrade.green:
        return scheme.onPrimaryContainer;
      case QualityGrade.amber:
        return scheme.onTertiaryContainer;
      case QualityGrade.red:
        return scheme.onErrorContainer;
    }
  }

  IconData _icon() {
    switch (grade) {
      case QualityGrade.green:
        return Icons.check_circle;
      case QualityGrade.amber:
        return Icons.warning_amber;
      case QualityGrade.red:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _bg(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(), size: 16, color: _fg(context)),
            const SizedBox(width: 6),
            Text(
              '$label: $value',
              style: theme.textTheme.labelMedium?.copyWith(
                color: _fg(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
