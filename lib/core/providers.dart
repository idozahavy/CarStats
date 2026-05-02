import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs) {
    final stored = _prefs.getString(StorageKeys.themeMode);
    if (stored != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == stored,
        orElse: () => ThemeMode.system,
      );
    }
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(StorageKeys.themeMode, mode.name);
    notifyListeners();
  }
}

class SettingsProvider extends ChangeNotifier {
  bool _devMode = false;
  final SharedPreferences _prefs;

  SettingsProvider(this._prefs) {
    _devMode = _prefs.getBool(StorageKeys.devMode) ?? false;
  }

  bool get devMode => _devMode;

  Future<void> setDevMode(bool value) async {
    _devMode = value;
    await _prefs.setBool(StorageKeys.devMode, value);
    notifyListeners();
  }
}

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  final SharedPreferences _prefs;

  LocaleProvider(this._prefs) {
    final stored = _prefs.getString(StorageKeys.locale);
    if (stored != null && stored.isNotEmpty) {
      _locale = Locale(stored);
    }
  }

  Locale? get locale => _locale;

  Future<void> setLocale(Locale? value) async {
    _locale = value;
    if (value == null) {
      await _prefs.remove(StorageKeys.locale);
    } else {
      await _prefs.setString(StorageKeys.locale, value.languageCode);
    }
    notifyListeners();
  }
}
