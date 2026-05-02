import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/chart_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../services/recording_engine.dart';
import '../recording_detail/recording_detail_screen.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final engine = context.read<RecordingEngine>();
        if (engine.state == RecordingState.recording ||
            engine.state == RecordingState.calibrating) {
          await engine.stopRecording();
        }
        if (context.mounted) {
          engine.reset();
          Navigator.of(context).pop();
        }
      },
      child: Consumer<RecordingEngine>(
        builder: (context, engine, _) {
          final warning = engine.lastWarning;
          if (warning != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              if (engine.lastWarning != warning) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(_warningText(l, warning))));
              engine.clearLastWarning();
            });
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(_title(l, engine.state)),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  if (engine.state == RecordingState.recording ||
                      engine.state == RecordingState.calibrating) {
                    await engine.stopRecording();
                  }
                  if (context.mounted) {
                    engine.reset();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            body: SafeArea(top: false, child: _buildBody(context, engine, l)),
          );
        },
      ),
    );
  }

  String _warningText(AppLocalizations l, RecordingWarning warning) {
    switch (warning) {
      case RecordingWarning.gpsServiceLost:
        return l.recording_warning_gps_lost;
    }
  }

  String _title(AppLocalizations l, RecordingState state) {
    switch (state) {
      case RecordingState.calibrating:
        return l.recording_appbar_calibrating;
      case RecordingState.recording:
        return l.recording_appbar_recording;
      case RecordingState.stopped:
        return l.recording_appbar_saved;
      case RecordingState.idle:
        return l.recording_appbar_ready;
    }
  }

  Widget _buildBody(
    BuildContext context,
    RecordingEngine engine,
    AppLocalizations l,
  ) {
    switch (engine.state) {
      case RecordingState.calibrating:
        return _CalibrationView(countdown: engine.calibrationCountdown);
      case RecordingState.recording:
        return _RecordingView(engine: engine);
      case RecordingState.stopped:
        final id = engine.currentRecordingId;
        if (id == null) {
          return Center(child: Text(l.recording_not_found));
        }
        return _StoppedView(recordingId: id);
      case RecordingState.idle:
        return Center(child: Text(l.recording_appbar_ready));
    }
  }
}

class _CalibrationView extends StatelessWidget {
  final int countdown;
  const _CalibrationView({required this.countdown});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$countdown',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.recording_calibrating_title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l.recording_calibrating_hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class _RecordingView extends StatelessWidget {
  final RecordingEngine engine;
  const _RecordingView({required this.engine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final snap = engine.latestSnapshot;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l.recording_speed_label,
                  value: snap?.gpsSpeedKmh?.toStringAsFixed(1) ?? '--',
                  unit: 'km/h',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: l.recording_accel_label,
                  value: snap?.forwardAccelG?.toStringAsFixed(3) ?? '--',
                  unit: 'g',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l.recording_pitch_label,
                  value: snap?.pitchDeg?.toStringAsFixed(1) ?? '--',
                  unit: '°',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: l.recording_roll_label,
                  value: snap?.rollDeg?.toStringAsFixed(1) ?? '--',
                  unit: '°',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l.recording_peak_accel_label,
                  value: snap?.peakForwardG.toStringAsFixed(3) ?? '--',
                  unit: 'g',
                  compact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: l.recording_peak_brake_label,
                  value: snap?.peakBrakeG.toStringAsFixed(3) ?? '--',
                  unit: 'g',
                  compact: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: l.recording_peak_lateral_label,
                  value: snap?.peakLateralG.toStringAsFixed(3) ?? '--',
                  unit: 'g',
                  compact: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                snap?.headingCalibrated == true
                    ? Icons.check_circle
                    : Icons.sync,
                size: 14,
                color: snap?.headingCalibrated == true
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                snap?.headingCalibrated == true
                    ? l.recording_heading_locked
                    : l.recording_heading_calibrating,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: snap?.headingCalibrated == true
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.recording_chart_speed_vs_accel,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(child: _LiveChart(engine: engine)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => engine.stopRecording(),
            icon: const Icon(Icons.stop),
            label: Text(l.recording_stop_button),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool compact;
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: compact
            ? const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
            : const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: compact
                  ? theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
            ),
            Text(unit, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _LiveChart extends StatelessWidget {
  final RecordingEngine engine;
  const _LiveChart({required this.engine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final spots = <FlSpot>[];
    for (final s in engine.snapshots) {
      if (s.gpsSpeedKmh != null && s.forwardAccelG != null) {
        spots.add(FlSpot(s.gpsSpeedKmh!, s.forwardAccelG!));
      }
    }

    if (spots.isEmpty) {
      return Center(
        child: Text(
          l.recording_chart_waiting_gps,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final displaySpots = downsample(spots, xMin: 0, xMax: 300);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 300,
        minY: -1.5,
        maxY: 1.5,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_speed_kmh,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              l.chart_axis_accel_g,
              style: const TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 10),
              ),
            ),
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
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoppedView extends StatelessWidget {
  final int recordingId;
  const _StoppedView({required this.recordingId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l.recording_saved_title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                final engine = context.read<RecordingEngine>();
                engine.reset();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RecordingDetailScreen(recordingId: recordingId),
                  ),
                );
              },
              child: Text(l.recording_view_button),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                final engine = context.read<RecordingEngine>();
                engine.reset();
                Navigator.of(context).pop();
              },
              child: Text(l.recording_back_home_button),
            ),
          ],
        ),
      ),
    );
  }
}
