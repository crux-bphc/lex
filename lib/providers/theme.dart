import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Theme extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.dark;
  }

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = NotifierProvider<_Theme, ThemeMode>(_Theme.new);
