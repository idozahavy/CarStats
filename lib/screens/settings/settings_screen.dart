import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(_themeName(themeProvider.themeMode)),
            onTap: () => _showThemePicker(context, themeProvider),
          ),
          const Divider(),
          const _SectionHeader(title: 'Developer'),
          SwitchListTile(
            secondary: const Icon(Icons.developer_mode),
            title: const Text('Dev Mode'),
            subtitle: const Text('Show raw sensor data during recording'),
            value: settingsProvider.devMode,
            onChanged: (value) => settingsProvider.setDevMode(value),
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemePicker(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: ThemeMode.values.map((mode) {
          final selected = mode == provider.themeMode;
          return ListTile(
            title: Text(_themeName(mode)),
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? Theme.of(dialogContext).colorScheme.primary : null,
            ),
            onTap: () {
              provider.setThemeMode(mode);
              Navigator.pop(dialogContext);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
