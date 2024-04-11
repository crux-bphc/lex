import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/preferences.dart';
import 'package:lex/router/router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await _setupGetIt();

  runApp(const MyApp());
}

Future<void> _setupGetIt() async {
  final prefs = await SharedPreferences.getInstance();
  GetIt.instance.registerSingleton<Preferences>(
    Preferences(prefs),
    dispose: (prefs) => prefs.dispose(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme(ThemeMode mode) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigoAccent,
      brightness: Brightness.dark,
    ).copyWith(
      background: const Color(0xFF1E2128),
      error: const Color(0xFFBF616A),
      onBackground: const Color(0xFFCACACE),
      onError: const Color(0xFFBF616A),
    );

    final theme = ThemeData.from(
      colorScheme: mode == ThemeMode.dark
          ? scheme
          : ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      useMaterial3: true,
    ).copyWith(splashFactory: NoSplash.splashFactory);

    return theme;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      themeMode: GetIt.instance<Preferences>().themeMode.watch(context),
      theme: _buildTheme(ThemeMode.light),
      darkTheme: _buildTheme(ThemeMode.dark),
    );
  }
}
