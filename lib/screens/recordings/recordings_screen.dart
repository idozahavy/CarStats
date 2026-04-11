import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/database.dart';
import '../recording_detail/recording_detail_screen.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  final _db = AppDatabase();
  List<Recording> _recordings = [];
  bool _loading = true;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recordings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recordings.isEmpty
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
                  itemCount: _recordings.length,
                  itemBuilder: (context, index) {
                    final rec = _recordings[index];
                    return _RecordingTile(
                      recording: rec,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecordingDetailScreen(recordingId: rec.id),
                          ),
                        );
                        _load(); // refresh in case of deletion
                      },
                      onDelete: () => _deleteRecording(rec),
                    );
                  },
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteRecording(rec.id);
      _load();
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
    final dateStr = DateFormat('MMM d, yyyy  HH:mm').format(recording.startedAt);
    final duration = Duration(milliseconds: recording.durationMs);
    final durationStr = '${duration.inMinutes}m ${duration.inSeconds % 60}s';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          recording.isDevRecording ? Icons.developer_mode : Icons.show_chart,
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
