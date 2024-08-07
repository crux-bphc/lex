import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

class Preferences {
  SharedPreferences? _prefs;

  final List<EffectCleanup> _cleanups = [];

  void initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode.value = _prefs!.getString('theme_mode') ?? 'dark';
    cmsToken.value = _prefs!.getString('cms_token') ?? '';

    _cleanups.addAll([
      effect(() => _prefs!.setString('theme_mode', _themeMode.value)),
      effect(() => _prefs!.setString('cms_token', cmsToken.value)),
    ]);
  }

  late final _themeMode = signal('dark');
  late final themeMode = computed(
    () => _themeMode.value == 'dark' ? ThemeMode.dark : ThemeMode.light,
  );

  void toggleTheme() {
    _themeMode.value = _themeMode.value == 'dark' ? 'light' : 'dark';
  }

  late final cmsToken = signal('');

  void dispose() {
    for (final cleanup in _cleanups) {
      cleanup();
    }
  }
}
