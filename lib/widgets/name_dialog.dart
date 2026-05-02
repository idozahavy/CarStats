import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Dialog asking for a recording name. Returns the trimmed name on confirm,
/// or `null` if the user cancels.
///
/// [title] and [confirmLabel] let the same dialog serve "name on start" and
/// "rename" flows. [initialName] pre-fills the field; if the trimmed value is
/// empty or > 200 chars (the schema constraint), confirm is disabled.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String initialName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName,
    ),
  );
}

class _NameDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String initialName;

  const _NameDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
  });

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller;
  late String _trimmed;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _trimmed = widget.initialName.trim();
    _controller.addListener(() {
      setState(() => _trimmed = _controller.text.trim());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _trimmed.isNotEmpty && _trimmed.length <= 200;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 200,
        decoration: InputDecoration(labelText: l.dialog_name_field_label),
        onSubmitted: (_) {
          if (_valid) Navigator.pop(context, _trimmed);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.dialog_cancel),
        ),
        FilledButton(
          onPressed: _valid ? () => Navigator.pop(context, _trimmed) : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
