import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

class Preferences {
  final SharedPreferences _prefs;

  late final List<EffectCleanup> _cleanups;

  Preferences(this._prefs) {
    _cleanups = [
      effect(() => _prefs.setString('theme_mode', _themeMode.value)),
      effect(() => _prefs.setString('cms_token', cmsToken.value)),
    ];
  }

  late final _themeMode = signal(_prefs.getString('theme_mode') ?? 'dark');
  late final themeMode = computed(
    () => _themeMode.value == 'dark' ? ThemeMode.dark : ThemeMode.light,
  );

  void toggleTheme() {
    _themeMode.value = _themeMode.value == 'dark' ? 'light' : 'dark';
  }

  late final cmsToken = signal(_prefs.getString('cms_token') ?? '');

  void dispose() {
    for (final cleanup in _cleanups) {
      cleanup();
    }
  }
}
