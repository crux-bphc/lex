import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/preferences.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:signals/signals_flutter.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final prefs = GetIt.instance<Preferences>();
    return IconButton(
      onPressed: prefs.toggleTheme,
      icon: Watch(
        (context) => Icon(
          prefs.themeMode.value == ThemeMode.light
              ? LucideIcons.moon
              : LucideIcons.sun,
        ),
      ),
    );
  }
}
