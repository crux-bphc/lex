import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/providers/preferences.dart';

class _ThemeMode extends Notifier<ThemeMode> {
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

final themeProvider = NotifierProvider<_ThemeMode, ThemeMode>(_ThemeMode.new);

ThemeData buildTheme(ThemeMode mode) {
  final scheme = ColorScheme.fromSeed(
          seedColor: Colors.indigoAccent, brightness: Brightness.dark)
      .copyWith(
    background: Color(0xAA1E2128),
    error: Color(0xAABF616A),
    onBackground: Color(0xAACACACE),
    onError: Color(0xAABF616A),
  );

  final theme = ThemeData.from(
      colorScheme: mode == ThemeMode.dark
          ? scheme
          : ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      useMaterial3: true);

  return theme;
}
