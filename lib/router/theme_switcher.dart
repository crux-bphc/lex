import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/providers/theme.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({
    this.iconSize,
    super.key,
  });

  final double? iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return IconButton(
      iconSize: iconSize,
      onPressed: ref.read(themeProvider.notifier).toggle,
      icon: Icon(theme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
    );
  }
}
