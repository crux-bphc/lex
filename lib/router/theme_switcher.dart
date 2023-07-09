import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/providers/theme.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return IconButton(
      onPressed: ref.read(themeProvider.notifier).toggle,
      icon: Icon(theme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
    );
  }
}
