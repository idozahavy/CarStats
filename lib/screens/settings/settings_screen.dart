import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../manage_cars/manage_cars_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings_title)),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            _SectionHeader(title: l.settings_appearance_section),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(l.settings_theme_label),
              subtitle: Text(_themeName(l, themeProvider.themeMode)),
              onTap: () => _showThemePicker(context, themeProvider, l),
            ),
            const Divider(),
            _SectionHeader(title: l.settings_language_section),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.settings_language_label),
              subtitle: Text(_localeName(l, localeProvider.locale)),
              onTap: () => _showLanguagePicker(context, localeProvider, l),
            ),
            const Divider(),
            _SectionHeader(title: l.settings_vehicles_section),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text(l.settings_my_cars_label),
              subtitle: Text(l.settings_my_cars_hint),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ManageCarsScreen(),
                ),
              ),
            ),
            const Divider(),
            _SectionHeader(title: l.settings_developer_section),
            SwitchListTile(
              secondary: const Icon(Icons.developer_mode),
              title: Text(l.settings_devmode_label),
              subtitle: Text(l.settings_devmode_hint),
              value: settingsProvider.devMode,
              onChanged: (value) => settingsProvider.setDevMode(value),
            ),
          ],
        ),
      ),
    );
  }

  String _themeName(AppLocalizations l, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l.settings_theme_system;
      case ThemeMode.light:
        return l.settings_theme_light;
      case ThemeMode.dark:
        return l.settings_theme_dark;
    }
  }

  String _localeName(AppLocalizations l, Locale? locale) {
    if (locale == null) return l.settings_language_system;
    switch (locale.languageCode) {
      case 'en':
        return l.settings_language_english;
      case 'he':
        return l.settings_language_hebrew;
      default:
        return locale.languageCode;
    }
  }

  void _showThemePicker(
    BuildContext context,
    ThemeProvider provider,
    AppLocalizations l,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l.settings_theme_picker_title),
        children: ThemeMode.values.map((mode) {
          final selected = mode == provider.themeMode;
          return ListTile(
            title: Text(_themeName(l, mode)),
            leading: Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? Theme.of(dialogContext).colorScheme.primary
                  : null,
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

  void _showLanguagePicker(
    BuildContext context,
    LocaleProvider provider,
    AppLocalizations l,
  ) {
    final options = <Locale?>[null, const Locale('en'), const Locale('he')];
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l.settings_language_picker_title),
        children: options.map((opt) {
          final selected = opt?.languageCode == provider.locale?.languageCode;
          return ListTile(
            title: Text(_localeName(l, opt)),
            leading: Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? Theme.of(dialogContext).colorScheme.primary
                  : null,
            ),
            onTap: () {
              provider.setLocale(opt);
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
