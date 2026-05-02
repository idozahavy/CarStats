import 'package:accel_stats/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocaleProvider', () {
    test('starts with null locale when no pref is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = LocaleProvider(prefs);

      expect(provider.locale, isNull);
    });

    test('reads stored locale from prefs on construction', () async {
      SharedPreferences.setMockInitialValues({'locale': 'he'});
      final prefs = await SharedPreferences.getInstance();
      final provider = LocaleProvider(prefs);

      expect(provider.locale, const Locale('he'));
    });

    test('setLocale persists language code and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = LocaleProvider(prefs);

      var notified = 0;
      provider.addListener(() => notified++);

      await provider.setLocale(const Locale('he'));

      expect(provider.locale, const Locale('he'));
      expect(prefs.getString('locale'), 'he');
      expect(notified, 1);
    });

    test('setLocale(null) clears the pref', () async {
      SharedPreferences.setMockInitialValues({'locale': 'he'});
      final prefs = await SharedPreferences.getInstance();
      final provider = LocaleProvider(prefs);
      expect(provider.locale, const Locale('he'));

      await provider.setLocale(null);

      expect(provider.locale, isNull);
      expect(prefs.getString('locale'), isNull);
    });
  });
}
