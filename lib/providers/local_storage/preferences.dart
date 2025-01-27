import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class Preferences {
  final SharedPreferences _prefs;

  Preferences(this._prefs);

  final List<EffectCleanup> _cleanups = [];

  void initialize() async {
    _themeMode.value = _prefs.getString('theme_mode') ?? 'dark';

    _cleanups.addAll([
      effect(() => _prefs.setString('theme_mode', _themeMode.value)),
    ]);
  }

  late final _themeMode = signal('dark');
  late final themeMode = computed(
    () => _themeMode.value == 'dark' ? ThemeMode.dark : ThemeMode.light,
  );

  void toggleTheme() {
    _themeMode.value = _themeMode.value == 'dark' ? 'light' : 'dark';
  }

  void dispose() {
    for (final cleanup in _cleanups) {
      cleanup();
    }
  }
}
