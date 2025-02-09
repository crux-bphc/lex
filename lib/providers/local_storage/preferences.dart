import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class Preferences {
  final SharedPreferences _prefs;

  Preferences(this._prefs);

  final List<EffectCleanup> _cleanups = [];

  void initialize() async {
    _cleanups.addAll([
      effect(() => _prefs.setString('theme_mode', _themeMode())),
      effect(
        () => _prefs.setBool(
          'is_disclaimer_accepted',
          isDisclaimerAccepted(),
        ),
      ),
      effect(() => _prefs.setDouble('playback_speed', playbackSpeed())),
      effect(() => _prefs.setDouble('playback_volume', playbackVolume())),
    ]);
  }

  late final _themeMode = signal(_prefs.getString('theme_mode') ?? 'dark');
  late final themeMode = computed(
    () => _themeMode.value == 'dark' ? ThemeMode.dark : ThemeMode.light,
  );

  void toggleTheme() {
    _themeMode.value = _themeMode.value == 'dark' ? 'light' : 'dark';
  }

  late final isDisclaimerAccepted =
      signal(_prefs.getBool('is_disclaimer_accepted') ?? false);

  late final playbackSpeed = signal(_prefs.getDouble('playback_speed') ?? 1.0);
  late final playbackVolume =
      signal(_prefs.getDouble('playback_volume') ?? 100.0);

  void dispose() {
    for (final cleanup in _cleanups) {
      cleanup();
    }
  }
}
