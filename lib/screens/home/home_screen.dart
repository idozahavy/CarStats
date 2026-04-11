import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/recording_engine.dart';
import '../recording/recording_screen.dart';
import '../recordings/recordings_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/providers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CarStats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              Icons.speed,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Car Acceleration\nMeasurement',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mount your phone anywhere in the car.\nThe app auto-calibrates for any orientation.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _startRecording(context),
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Start Recording'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecordingsScreen()),
              ),
              icon: const Icon(Icons.list),
              label: const Text('View Recordings'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final engine = context.read<RecordingEngine>();

    final name = 'Run ${DateTime.now().toString().substring(0, 16)}';
    await engine.startRecording(name: name, isDev: settings.devMode);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordingScreen()),
    );
  }
}
