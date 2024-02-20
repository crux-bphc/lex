import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/providers/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return IconButton(
      onPressed: ref.read(themeProvider.notifier).toggle,
      icon: Icon(theme == ThemeMode.light ? LucideIcons.sun : LucideIcons.moon),
    );
  }
}
