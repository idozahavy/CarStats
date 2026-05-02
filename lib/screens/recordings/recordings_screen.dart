import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../services/export_service.dart';
import '../../widgets/name_dialog.dart';
import '../recording_detail/recording_detail_screen.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

enum _RecordingFilter { all, user, dev }

class _RecordingsScreenState extends State<RecordingsScreen> {
  late final RecordingStore _db;
  List<Recording> _recordings = [];
  bool _loading = true;
  _RecordingFilter _filter = _RecordingFilter.all;

  @override
  void initState() {
    super.initState();
    _db = context.read<RecordingStore>();
    _load();
  }

  Future<void> _load() async {
    final recordings = await _db.getAllRecordings();
    setState(() {
      _recordings = recordings;
      _loading = false;
    });
  }

  List<Recording> get _filteredRecordings => switch (_filter) {
    _RecordingFilter.all => _recordings,
    _RecordingFilter.user =>
      _recordings.where((r) => !r.isDevRecording).toList(),
    _RecordingFilter.dev => _recordings.where((r) => r.isDevRecording).toList(),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.recordings_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: l.recordings_import_tooltip,
            onPressed: () => _importRecording(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: l.recordings_filter_all,
                          selected: _filter == _RecordingFilter.all,
                          onSelected: () =>
                              setState(() => _filter = _RecordingFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l.recordings_filter_user,
                          selected: _filter == _RecordingFilter.user,
                          onSelected: () =>
                              setState(() => _filter = _RecordingFilter.user),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l.recordings_filter_dev,
                          selected: _filter == _RecordingFilter.dev,
                          onSelected: () =>
                              setState(() => _filter = _RecordingFilter.dev),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredRecordings.isEmpty
                        ? _EmptyState(
                            isFiltered: _recordings.isNotEmpty,
                            onStart: () => Navigator.of(context).pop(),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredRecordings.length,
                            itemBuilder: (context, index) {
                              final rec = _filteredRecordings[index];
                              return _RecordingTile(
                                recording: rec,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecordingDetailScreen(
                                        recordingId: rec.id,
                                      ),
                                    ),
                                  );
                                  _load();
                                },
                                onLongPress: () => _renameRecording(rec),
                                onDelete: () => _deleteRecording(rec),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _renameRecording(Recording rec) async {
    final l = AppLocalizations.of(context)!;
    final newName = await showNameDialog(
      context,
      title: l.recordings_rename_dialog_title,
      confirmLabel: l.recordings_rename_dialog_confirm,
      initialName: rec.name,
    );
    if (newName == null || newName == rec.name) return;
    await _db.renameRecording(rec.id, newName);
    _load();
  }

  Future<void> _deleteRecording(Recording rec) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l.recordings_delete_title),
          content: Text(l.recordings_delete_message(rec.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.recordings_delete_cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.recordings_delete_confirm),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _db.deleteRecording(rec.id);
      _load();
    }
  }

  Future<void> _importRecording(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    try {
      final recordingId = await ExportService.importRecording(_db);
      if (recordingId == null) return;
      _load();
      messenger.showSnackBar(
        SnackBar(content: Text(l.recordings_import_success)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.recordings_import_failed(e.toString()))),
      );
    }
  }
}

class _RecordingTile extends StatelessWidget {
  final Recording recording;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const _RecordingTile({
    required this.recording,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat(
      'MMM d, yyyy  HH:mm',
    ).format(recording.startedAt);
    final duration = Duration(milliseconds: recording.durationMs);
    final durationStr = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          recording.isDevRecording ? Icons.science : Icons.route,
          color: theme.colorScheme.primary,
        ),
        title: Text(recording.name),
        subtitle: Text('$dateStr  •  $durationStr'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onStart;

  const _EmptyState({required this.isFiltered, required this.onStart});

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
              Icons.directions_car_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? l.recordings_empty_filtered
                  : l.recordings_empty_title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 8),
              Text(
                l.recordings_empty_hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.fiber_manual_record),
                label: Text(l.recordings_empty_cta),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
