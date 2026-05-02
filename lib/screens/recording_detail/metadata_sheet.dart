import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../manage_cars/manage_cars_screen.dart';

/// Shows the metadata edit sheet for [recordingId]. Returns `true` if the user
/// saved (so the caller can reload metadata), `false`/`null` otherwise.
Future<bool?> showMetadataSheet(
  BuildContext context, {
  required int recordingId,
  RecordingMetadataData? initial,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _MetadataSheet(
      recordingId: recordingId,
      initial: initial,
    ),
  );
}

class _MetadataSheet extends StatefulWidget {
  final int recordingId;
  final RecordingMetadataData? initial;

  const _MetadataSheet({required this.recordingId, this.initial});

  @override
  State<_MetadataSheet> createState() => _MetadataSheetState();
}

class _MetadataSheetState extends State<_MetadataSheet> {
  late final TextEditingController _driveModeCtrl;
  late final TextEditingController _passengersCtrl;
  late final TextEditingController _fuelLevelCtrl;
  late final TextEditingController _tyreCtrl;
  late final TextEditingController _weatherCtrl;
  late final TextEditingController _freeTextCtrl;
  int? _carProfileId;
  List<CarProfile> _cars = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    _driveModeCtrl = TextEditingController(text: m?.driveMode ?? '');
    _passengersCtrl =
        TextEditingController(text: m?.passengerCount?.toString() ?? '');
    _fuelLevelCtrl =
        TextEditingController(text: m?.fuelLevelPercent?.toString() ?? '');
    _tyreCtrl = TextEditingController(text: m?.tyreType ?? '');
    _weatherCtrl = TextEditingController(text: m?.weatherNote ?? '');
    _freeTextCtrl = TextEditingController(text: m?.freeText ?? '');
    _carProfileId = m?.carProfileId;
    _loadCars();
  }

  Future<void> _loadCars() async {
    final db = context.read<RecordingStore>();
    final cars = await db.getAllCarProfiles();
    if (!mounted) return;
    setState(() {
      _cars = cars;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _driveModeCtrl.dispose();
    _passengersCtrl.dispose();
    _fuelLevelCtrl.dispose();
    _tyreCtrl.dispose();
    _weatherCtrl.dispose();
    _freeTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final db = context.read<RecordingStore>();
    final navigator = Navigator.of(context);

    int? toIntOrNull(String t) {
      final s = t.trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    await db.upsertMetadata(
      RecordingMetadataCompanion.insert(
        recordingId: widget.recordingId,
        carProfileId: Value(_carProfileId),
        driveMode: Value(_driveModeCtrl.text.trim()),
        passengerCount: Value(toIntOrNull(_passengersCtrl.text)),
        fuelLevelPercent: Value(toIntOrNull(_fuelLevelCtrl.text)),
        tyreType: Value(_tyreCtrl.text.trim()),
        weatherNote: Value(_weatherCtrl.text.trim()),
        freeText: Value(_freeTextCtrl.text.trim()),
      ),
    );
    navigator.pop(true);
  }

  Future<void> _openManageCars() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManageCarsScreen()),
    );
    if (!mounted) return;
    await _loadCars();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + viewInsets),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l.detail_metadata_sheet_title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<int?>(
                key: const Key('car_profile_dropdown'),
                initialValue: _carProfileId,
                decoration: InputDecoration(
                  labelText: l.detail_metadata_field_car,
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l.detail_metadata_car_none),
                  ),
                  for (final c in _cars)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => _carProfileId = v),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _openManageCars,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.detail_metadata_car_add_new),
              ),
            ),
            TextField(
              controller: _driveModeCtrl,
              decoration: InputDecoration(
                labelText: l.detail_metadata_field_drive_mode,
              ),
            ),
            TextField(
              controller: _passengersCtrl,
              decoration: InputDecoration(
                labelText: l.detail_metadata_field_passenger_count,
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _fuelLevelCtrl,
              decoration: InputDecoration(
                labelText: l.detail_metadata_field_fuel_level,
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _tyreCtrl,
              decoration: InputDecoration(
                labelText: l.detail_metadata_field_tyre_type,
              ),
            ),
            TextField(
              controller: _weatherCtrl,
              decoration: InputDecoration(
                labelText: l.detail_metadata_field_weather,
              ),
            ),
            TextField(
              controller: _freeTextCtrl,
              decoration: InputDecoration(
                labelText: l.detail_metadata_field_free_text,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.pop(context, false),
                  child: Text(l.detail_metadata_cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(l.detail_metadata_save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
