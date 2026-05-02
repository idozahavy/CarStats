import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/recording_engine.dart';
import '../../widgets/name_dialog.dart';
import '../recording/recording_screen.dart';
import '../recordings/recordings_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/providers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
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
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.speed, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l.home_title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.home_subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _startRecording(context),
                icon: const Icon(Icons.fiber_manual_record),
                label: Text(l.home_startButton),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecordingsScreen()),
                ),
                icon: const Icon(Icons.list),
                label: Text(l.home_viewRecordingsButton),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startRecording(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final engine = context.read<RecordingEngine>();
    final l = AppLocalizations.of(context)!;

    final defaultName =
        '${l.home_default_recording_name_prefix} ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}';

    final name = await showNameDialog(
      context,
      title: l.home_name_dialog_title,
      confirmLabel: l.home_name_dialog_confirm,
      initialName: defaultName,
    );
    if (name == null) return;

    await engine.startRecording(name: name, isDev: settings.devMode);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordingScreen()),
    );
  }
}
