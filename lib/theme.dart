import 'package:flutter/material.dart';

final _darkScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color(0xFF1E2128),
  primary: const Color(0xFFEBCB8B),
  onPrimary: const Color(0xFF402D00),
  secondary: const Color(0xFFB48EAD),
  secondaryFixed: const Color(0xFFBF616A),
  onSecondary: const Color(0xFF432740),
  tertiary: const Color(0xFFA3BE8C),
  onTertiary: const Color(0xFF213611),
  error: const Color(0xFFFFB2B7),
  onError: const Color(0xFF5D1521),
  surface: const Color(0xFF1E2128),
  onSurface: const Color(0xFFE5E2E2),
  onInverseSurface: const Color(0xFF434C5D),
  surfaceContainerHigh: const Color(0xFF2E3440),
  surfaceContainerHighest: const Color(0xFF2A2F38),
  outline: const Color(0xFF434C5D),
  outlineVariant: const Color(0xFFC3C3C3),
);

// this is temporary
final _lightScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color(0xFFD8DEE9),
  primary: const Color(0xFF8E702F),
  onPrimary: const Color(0xFF402D00),
  secondary: const Color(0xFFB48EAD),
  secondaryFixed: const Color(0xFFBF616A),
  onSecondary: const Color(0xFF432740),
  tertiary: const Color(0xFFA3BE8C),
  onTertiary: const Color(0xFF213611),
  error: const Color(0xFFFFB2B7),
  onError: const Color(0xFF5D1521),
  surface: const Color(0xFFECEFF4),
  onInverseSurface: const Color(0xFF434C5D),
  surfaceContainerHigh: const Color(0xFFe5e9f0),
);

ThemeData buildTheme(ThemeMode mode) {
  final scheme = mode == ThemeMode.dark ? _darkScheme : _lightScheme;

  final inputDecoration = InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    isDense: true,
  );

  final searchBarTheme = SearchBarThemeData(
    constraints: const BoxConstraints(),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: const WidgetStatePropertyAll(TextStyle(height: 1)),
    backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
    padding: const WidgetStatePropertyAll(EdgeInsets.fromLTRB(14, 7, 14, 8)),
    side: WidgetStatePropertyAll(BorderSide(width: 1, color: scheme.onSurface)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  final buttonStyle = ButtonStyle(
    mouseCursor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
  );

  final outlineButtonTheme = OutlinedButtonThemeData(
    style: buttonStyle.copyWith(
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.3),
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? null : scheme.primary,
      ),
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          width: 1,
          color: states.contains(WidgetState.disabled)
              ? scheme.outlineVariant.withOpacity(0.3)
              : scheme.primary,
        ),
      ),
    ),
  );

  final dialogTheme = DialogTheme(
    backgroundColor: scheme.surfaceContainerHigh,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: BorderSide(color: scheme.outline, width: 1),
    ),
    titleTextStyle: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: scheme.primary,
    ),
    contentTextStyle: TextStyle(fontSize: 21, color: scheme.onSurface),
    barrierColor: Colors.black.withOpacity(0.3),
  );

  final tooltipTheme = TooltipThemeData(
    preferBelow: false,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    splashFactory: NoSplash.splashFactory,
    scaffoldBackgroundColor: scheme.surface,
    inputDecorationTheme: inputDecoration,
    searchBarTheme: searchBarTheme,
    outlinedButtonTheme: outlineButtonTheme,
    dialogTheme: dialogTheme,
    tooltipTheme: tooltipTheme,
  );
}
