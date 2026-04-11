import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/database.dart';
import '../../services/export_service.dart';
import '../recording_detail/recording_detail_screen.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

enum _RecordingFilter { all, user, dev }

class _RecordingsScreenState extends State<RecordingsScreen> {
  final _db = AppDatabase();
  List<Recording> _recordings = [];
  bool _loading = true;
  _RecordingFilter _filter = _RecordingFilter.all;

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import',
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
                          label: 'All',
                          selected: _filter == _RecordingFilter.all,
                          onSelected: () =>
                              setState(() => _filter = _RecordingFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'User',
                          selected: _filter == _RecordingFilter.user,
                          onSelected: () =>
                              setState(() => _filter = _RecordingFilter.user),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Dev',
                          selected: _filter == _RecordingFilter.dev,
                          onSelected: () =>
                              setState(() => _filter = _RecordingFilter.dev),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredRecordings.isEmpty
                        ? Center(
                            child: Text(
                              'No recordings yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
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

  Future<void> _deleteRecording(Recording rec) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: Text('Delete "${rec.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteRecording(rec.id);
      _load();
    }
  }

  Future<void> _importRecording(BuildContext context) async {
    try {
      final recordingId = await ExportService.importRecording();
      if (recordingId == null) return;
      _load();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Recording imported')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }
}

class _RecordingTile extends StatelessWidget {
  final Recording recording;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecordingTile({
    required this.recording,
    required this.onTap,
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
