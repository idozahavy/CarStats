import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/chart_utils.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';

class ComparisonScreen extends StatefulWidget {
  final int idA;
  final int idB;

  const ComparisonScreen({super.key, required this.idA, required this.idB});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _AlignedRecording {
  final Recording recording;
  final List<SensorSample> samples;
  final int? firstMovementUs;

  const _AlignedRecording({
    required this.recording,
    required this.samples,
    required this.firstMovementUs,
  });

  bool get hasMovement => firstMovementUs != null;
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  late final RecordingStore _db;
  _AlignedRecording? _a;
  _AlignedRecording? _b;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _db = context.read<RecordingStore>();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _loadOne(widget.idA),
      _loadOne(widget.idB),
    ]);
    if (!mounted) return;
    setState(() {
      _a = results[0];
      _b = results[1];
      _loading = false;
    });
  }

  Future<_AlignedRecording> _loadOne(int id) async {
    final rec = await _db.getRecording(id);
    final samples = await _db.getSamplesForRecording(id);
    return _AlignedRecording(
      recording: rec,
      samples: samples,
      firstMovementUs: _findFirstMovement(samples),
    );
  }

  static int? _findFirstMovement(List<SensorSample> samples) {
    for (final s in samples) {
      final speed = s.gpsSpeed;
      if (speed != null && speed * 3.6 >= 1) return s.timestampUs;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.compare_title)),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, l),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    final a = _a!;
    final b = _b!;
    final colorA = theme.colorScheme.primary;
    final colorB = theme.colorScheme.tertiary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _RecordingHeaderCard(
                  recording: a.recording,
                  color: colorA,
                  label: l.compare_recording_a_label,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RecordingHeaderCard(
                  recording: b.recording,
                  color: colorB,
                  label: l.compare_recording_b_label,
                ),
              ),
            ],
          ),
          if (!a.hasMovement)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.compare_no_movement(a.recording.name)),
            ),
          if (!b.hasMovement)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.compare_no_movement(b.recording.name)),
            ),
          const SizedBox(height: 24),
          Text(
            l.compare_chart_speed_time,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: _OverlayChart(
              a: a,
              b: b,
              colorA: colorA,
              colorB: colorB,
              kind: _ChartKind.speed,
            ),
          ),
          const SizedBox(height: 8),
          _Legend(a: a, b: b, colorA: colorA, colorB: colorB),
          const SizedBox(height: 24),
          Text(
            l.compare_chart_accel_time,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: _OverlayChart(
              a: a,
              b: b,
              colorA: colorA,
              colorB: colorB,
              kind: _ChartKind.accel,
            ),
          ),
          const SizedBox(height: 8),
          _Legend(a: a, b: b, colorA: colorA, colorB: colorB),
        ],
      ),
    );
  }
}

class _RecordingHeaderCard extends StatelessWidget {
  final Recording recording;
  final Color color;
  final String label;

  const _RecordingHeaderCard({
    required this.recording,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = Duration(milliseconds: recording.durationMs);
    final durationStr = '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ColorDot(color: color),
                const SizedBox(width: 6),
                Text(label, style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              recording.name,
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(durationStr, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Legend extends StatelessWidget {
  final _AlignedRecording a;
  final _AlignedRecording b;
  final Color colorA;
  final Color colorB;

  const _Legend({
    required this.a,
    required this.b,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _LegendEntry(color: colorA, name: a.recording.name, theme: theme),
        _LegendEntry(color: colorB, name: b.recording.name, theme: theme),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  final Color color;
  final String name;
  final ThemeData theme;

  const _LegendEntry({
    required this.color,
    required this.name,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ColorDot(color: color),
        const SizedBox(width: 6),
        Text(name, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

enum _ChartKind { speed, accel }

class _OverlayChart extends StatelessWidget {
  final _AlignedRecording a;
  final _AlignedRecording b;
  final Color colorA;
  final Color colorB;
  final _ChartKind kind;

  const _OverlayChart({
    required this.a,
    required this.b,
    required this.colorA,
    required this.colorB,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final spotsA = _alignedSpots(a);
    final spotsB = _alignedSpots(b);
    final maxX = _maxX(spotsA, spotsB);
    final interval = _timeInterval(maxX);

    final lines = <LineChartBarData>[];
    if (spotsA.isNotEmpty) {
      lines.add(
        LineChartBarData(
          spots: downsample(spotsA),
          isCurved: false,
          color: colorA,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      );
    }
    if (spotsB.isNotEmpty) {
      lines.add(
        LineChartBarData(
          spots: downsample(spotsB),
          isCurved: false,
          color: colorB,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    final yBounds = _yBounds(spotsA, spotsB);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: yBounds.min,
        maxY: yBounds.max,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              l.compare_axis_time_since_movement,
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
              kind == _ChartKind.speed
                  ? l.chart_axis_kmh
                  : l.chart_axis_accel_g,
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
        lineBarsData: lines,
      ),
    );
  }

  List<FlSpot> _alignedSpots(_AlignedRecording rec) {
    final firstMoveUs = rec.firstMovementUs;
    if (firstMoveUs == null) return const [];
    final spots = <FlSpot>[];
    for (final s in rec.samples) {
      if (s.timestampUs < firstMoveUs) continue;
      final t = (s.timestampUs - firstMoveUs) / 1e6;
      switch (kind) {
        case _ChartKind.speed:
          final v = s.gpsSpeed;
          if (v != null) spots.add(FlSpot(t, v * 3.6));
          break;
        case _ChartKind.accel:
          final v = s.forwardAccel;
          if (v != null) spots.add(FlSpot(t, v / 9.81));
          break;
      }
    }
    return spots;
  }

  double _maxX(List<FlSpot> a, List<FlSpot> b) {
    double m = 0;
    if (a.isNotEmpty && a.last.x > m) m = a.last.x;
    if (b.isNotEmpty && b.last.x > m) m = b.last.x;
    return m == 0 ? 1 : m;
  }

  ({double min, double max}) _yBounds(List<FlSpot> a, List<FlSpot> b) {
    if (kind == _ChartKind.accel) {
      return (min: -1.5, max: 1.5);
    }
    double observed = 0;
    for (final s in a) {
      if (s.y > observed) observed = s.y;
    }
    for (final s in b) {
      if (s.y > observed) observed = s.y;
    }
    final maxY = ((observed / 50).ceil() * 50).toDouble().clamp(50.0, 400.0);
    return (min: 0, max: maxY);
  }
}

double _timeInterval(double maxSeconds) {
  if (maxSeconds <= 30) return 5;
  if (maxSeconds <= 60) return 10;
  if (maxSeconds <= 180) return 30;
  if (maxSeconds <= 600) return 60;
  return 120;
}
