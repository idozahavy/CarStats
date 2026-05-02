import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';

class ManageCarsScreen extends StatefulWidget {
  const ManageCarsScreen({super.key});

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  late final RecordingStore _db;
  List<CarProfile> _cars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _db = context.read<RecordingStore>();
    _load();
  }

  Future<void> _load() async {
    final cars = await _db.getAllCarProfiles();
    if (!mounted) return;
    setState(() {
      _cars = cars;
      _loading = false;
    });
  }

  Future<void> _addOrEdit(CarProfile? car) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _CarFormDialog(car: car),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(CarProfile car) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.manage_cars_delete_title),
        content: Text(l.manage_cars_delete_message(car.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.manage_cars_delete_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l.manage_cars_delete_confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteCarProfile(car.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.manage_cars_title)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l.manage_cars_add_button),
        onPressed: () => _addOrEdit(null),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _cars.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.manage_cars_empty_title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.manage_cars_empty_hint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _cars.length,
                itemBuilder: (_, i) {
                  final car = _cars[i];
                  final subtitle = [
                    if (car.make.isNotEmpty) car.make,
                    if (car.model.isNotEmpty) car.model,
                    if (car.year != null) '${car.year}',
                  ].join(' · ');
                  return Dismissible(
                    key: ValueKey(car.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      color: theme.colorScheme.errorContainer,
                      padding: const EdgeInsetsDirectional.only(end: 24),
                      child: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      await _delete(car);
                      return false;
                    },
                    child: ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text(car.name),
                      subtitle: subtitle.isEmpty ? null : Text(subtitle),
                      onTap: () => _addOrEdit(car),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CarFormDialog extends StatefulWidget {
  final CarProfile? car;
  const _CarFormDialog({this.car});

  @override
  State<_CarFormDialog> createState() => _CarFormDialogState();
}

class _CarFormDialogState extends State<_CarFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  String _fuelType = '';
  String _transmission = '';

  static const _fuelOptions = ['', 'petrol', 'diesel', 'electric', 'hybrid'];
  static const _transmissionOptions = ['', 'auto', 'manual', 'dct'];

  @override
  void initState() {
    super.initState();
    final c = widget.car;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _makeCtrl = TextEditingController(text: c?.make ?? '');
    _modelCtrl = TextEditingController(text: c?.model ?? '');
    _yearCtrl = TextEditingController(text: c?.year?.toString() ?? '');
    _fuelType = c?.fuelType ?? '';
    _transmission = c?.transmission ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final make = _makeCtrl.text.trim();
    final model = _modelCtrl.text.trim();
    final year = int.tryParse(_yearCtrl.text.trim());
    final db = context.read<RecordingStore>();
    final navigator = Navigator.of(context);

    if (widget.car == null) {
      await db.insertCarProfile(
        CarProfilesCompanion.insert(
          name: name,
          make: Value(make),
          model: Value(model),
          year: Value(year),
          fuelType: Value(_fuelType),
          transmission: Value(_transmission),
        ),
      );
    } else {
      await db.updateCarProfile(
        CarProfilesCompanion(
          id: Value(widget.car!.id),
          name: Value(name),
          make: Value(make),
          model: Value(model),
          year: Value(year),
          fuelType: Value(_fuelType),
          transmission: Value(_transmission),
        ),
      );
    }
    navigator.pop(true);
  }

  String _fuelLabel(AppLocalizations l, String value) {
    switch (value) {
      case 'petrol':
        return l.manage_cars_fuel_petrol;
      case 'diesel':
        return l.manage_cars_fuel_diesel;
      case 'electric':
        return l.manage_cars_fuel_electric;
      case 'hybrid':
        return l.manage_cars_fuel_hybrid;
      default:
        return l.manage_cars_fuel_other;
    }
  }

  String _transmissionLabel(AppLocalizations l, String value) {
    switch (value) {
      case 'auto':
        return l.manage_cars_transmission_auto;
      case 'manual':
        return l.manage_cars_transmission_manual;
      case 'dct':
        return l.manage_cars_transmission_dct;
      default:
        return l.manage_cars_transmission_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isNew = widget.car == null;
    return AlertDialog(
      title: Text(isNew ? l.manage_cars_new_title : l.manage_cars_edit_title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l.manage_cars_field_name,
                ),
                maxLength: 100,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return l.manage_cars_field_name;
                  return null;
                },
              ),
              TextFormField(
                controller: _makeCtrl,
                decoration: InputDecoration(
                  labelText: l.manage_cars_field_make,
                ),
              ),
              TextFormField(
                controller: _modelCtrl,
                decoration: InputDecoration(
                  labelText: l.manage_cars_field_model,
                ),
              ),
              TextFormField(
                controller: _yearCtrl,
                decoration: InputDecoration(
                  labelText: l.manage_cars_field_year,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _fuelType,
                decoration: InputDecoration(
                  labelText: l.manage_cars_field_fuel_type,
                ),
                items: _fuelOptions
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(_fuelLabel(l, v)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _fuelType = v ?? ''),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _transmission,
                decoration: InputDecoration(
                  labelText: l.manage_cars_field_transmission,
                ),
                items: _transmissionOptions
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(_transmissionLabel(l, v)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _transmission = v ?? ''),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.manage_cars_delete_cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l.manage_cars_save),
        ),
      ],
    );
  }
}
