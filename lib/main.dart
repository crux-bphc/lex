import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/auth/keycloak_auth.dart';
import 'package:lex/providers/preferences.dart';
import 'package:lex/router/router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  _setupGetIt();

  runApp(const MyApp());
}

void _setupGetIt() {
  GetIt.instance.registerSingletonAsync<Preferences>(
    () async {
      final prefs = await SharedPreferences.getInstance();
      return Preferences(prefs);
    },
    dispose: (prefs) => prefs.dispose(),
  );

  GetIt.instance.registerSingletonAsync<AuthProvider>(
    () async {
      final auth = KeycloakAuthProvider();
      await auth.initialise();
      return auth;
    },
    dispose: (auth) => auth.dispose(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance.allReady(),
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: (snapshot.connectionState == ConnectionState.done)
              ? MaterialApp.router(
                  key: const ValueKey("Loaded"),
                  routerConfig: router,
                  themeMode:
                      GetIt.instance<Preferences>().themeMode.watch(context),
                  theme: _buildTheme(ThemeMode.light),
                  darkTheme: _buildTheme(ThemeMode.dark),
                )
              : const _InitialLoadingPage(),
        );
      },
    );
  }
}

class _InitialLoadingPage extends StatelessWidget {
  const _InitialLoadingPage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: _buildTheme(ThemeMode.dark),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Center(
          child: Text(
            "Lex",
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.displayLarge?.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

ThemeData _buildTheme(ThemeMode mode) {
  final scheme = ColorScheme.fromSeed(
    seedColor: Colors.indigoAccent,
    brightness: Brightness.dark,
  ).copyWith(
    surface: const Color(0xFF1E2128),
    error: const Color(0xFFBF616A),
    onSurface: const Color(0xFFCACACE),
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
