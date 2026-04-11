import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/chart_utils.dart';
import '../../data/database/database.dart';

class RecordingDetailScreen extends StatefulWidget {
  final int recordingId;
  const RecordingDetailScreen({super.key, required this.recordingId});

  @override
  State<RecordingDetailScreen> createState() => _RecordingDetailScreenState();
}

class _RecordingDetailScreenState extends State<RecordingDetailScreen> {
  final _db = AppDatabase();
  Recording? _recording;
  List<SensorSample> _samples = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rec = await _db.getRecording(widget.recordingId);
    final samples = await _db.getSamplesForRecording(widget.recordingId);
    setState(() {
      _recording = rec;
      _samples = samples;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_recording?.name ?? 'Recording'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _samples.isEmpty
              ? Center(
                  child: Text(
                    'No data recorded',
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
                      _SummaryCards(recording: _recording!, samples: _samples),
                      const SizedBox(height: 24),
                      Text('Speed vs Acceleration', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: _SpeedAccelChart(samples: _samples),
                      ),
                      const SizedBox(height: 24),
                      Text('Acceleration over Time', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: _AccelTimeChart(samples: _samples),
                      ),
                      const SizedBox(height: 24),
                      Text('Speed over Time', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: _SpeedTimeChart(samples: _samples),
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
    // Compute summary stats
    double maxSpeed = 0;
    double maxAccel = 0;
    double minAccel = 0;

    for (final s in samples) {
      final speed = (s.gpsSpeed ?? 0) * 3.6; // m/s to km/h
      if (speed > maxSpeed) maxSpeed = speed;
      final accel = (s.forwardAccel ?? 0) / 9.81; // m/s² to g
      if (accel > maxAccel) maxAccel = accel;
      if (accel < minAccel) minAccel = accel;
    }

    final duration = Duration(milliseconds: recording.durationMs);
    final durationStr = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(child: _MiniCard(label: 'Duration', value: durationStr)),
        Expanded(child: _MiniCard(label: 'Max Speed', value: '${maxSpeed.toStringAsFixed(1)} km/h')),
        Expanded(child: _MiniCard(label: 'Max Accel', value: '${maxAccel.toStringAsFixed(2)} g')),
        Expanded(child: _MiniCard(label: 'Max Brake', value: '${minAccel.toStringAsFixed(2)} g')),
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
            Text(label, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
    final spots = <FlSpot>[];
    for (final s in samples) {
      if (s.gpsSpeed != null && s.forwardAccel != null) {
        spots.add(FlSpot(s.gpsSpeed! * 3.6, s.forwardAccel! / 9.81));
      }
    }
    if (spots.isEmpty) return const Center(child: Text('No GPS+accel data'));

    final displaySpots = downsample(spots);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Speed (km/h)', style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Accel (g)', style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: displaySpots,
            isCurved: true,
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
    final spots = <FlSpot>[];
    for (final s in samples) {
      if (s.forwardAccel != null) {
        spots.add(FlSpot(s.timestampUs / 1e6, s.forwardAccel! / 9.81));
      }
    }
    if (spots.isEmpty) return const Center(child: Text('No acceleration data'));

    final displaySpots = downsample(spots);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Time (s)', style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('Accel (g)', style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: displaySpots,
            isCurved: true,
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
    final spots = <FlSpot>[];
    for (final s in samples) {
      if (s.gpsSpeed != null) {
        spots.add(FlSpot(s.timestampUs / 1e6, s.gpsSpeed! * 3.6));
      }
    }
    if (spots.isEmpty) return const Center(child: Text('No GPS speed data'));

    final displaySpots = downsample(spots);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Time (s)', style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('km/h', style: TextStyle(fontSize: 12)),
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: displaySpots,
            isCurved: true,
            color: theme.colorScheme.secondary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
