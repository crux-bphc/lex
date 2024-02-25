import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

class Preferences {
  final SharedPreferences _prefs;

  late final EffectCleanup _cleanup;

  Preferences(this._prefs) {
    _cleanup = effect(() {
      _prefs.setString('theme_mode', _themeMode.value);
      debugPrint("set theme");
    });
  }

  late final _themeMode = signal(_prefs.getString('theme_mode') ?? 'dark');
  late final themeMode = computed(
    () => _themeMode.value == 'dark' ? ThemeMode.dark : ThemeMode.light,
  );

  void toggleTheme() {
    _themeMode.value = _themeMode.value == 'dark' ? 'light' : 'dark';
  }

  void dispose() {
    _cleanup();
  }
}
