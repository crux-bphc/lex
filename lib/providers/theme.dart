import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/providers/preferences.dart';

class _Theme extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(preferencesProvider);
    final savedTheme = prefs.getString("theme") ?? "light";
    ref.listenSelf((previous, next) {
      final themeString = next == ThemeMode.light ? "light" : "dark";
      prefs.setString('theme', themeString);
    });
    return savedTheme == "light" ? ThemeMode.light : ThemeMode.dark;
  }

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = NotifierProvider<_Theme, ThemeMode>(_Theme.new);
