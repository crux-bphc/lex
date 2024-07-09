import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/auth/keycloak_auth.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/providers/preferences.dart';
import 'package:lex/router/router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:signals/signals_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  _setupGetIt();

  runApp(const MyApp());
}

void _setupGetIt() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<Preferences>(
    Preferences()..initialize(),
    dispose: (prefs) => prefs.dispose(),
  );

  getIt.registerSingletonAsync<AuthProvider>(
    () async {
      final auth = KeycloakAuthProvider();
      await auth.initialise();
      return auth;
    },
    dispose: (auth) => auth.dispose(),
  );

  getIt.registerSingletonWithDependencies<LexBackend>(
    () => LexBackend(getIt<AuthProvider>()),
    dependsOn: [AuthProvider],
  );

  getIt.registerSingletonWithDependencies<MultipartusService>(
    () => MultipartusService(getIt<LexBackend>()),
    dependsOn: [LexBackend],
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  final getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();

    _getItReady();
  }

  void _getItReady() async {
    await getIt.allReady();

    // at this point we are almost certainly mounted
    // but to keep the linter happy:
    if (!mounted) return;
    final isLoggedIn = getIt<AuthProvider>().isLoggedIn;
    isLoggedIn.listen(context, () {
      router.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: const ValueKey("Loaded"),
      routerConfig: router,
      themeMode: getIt<Preferences>().themeMode.watch(context),
      theme: _buildTheme(ThemeMode.light),
      darkTheme: _buildTheme(ThemeMode.dark),
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
    onSurface: const Color(0xFFF8F8FF),
    onError: const Color(0xFFBF616A),
    secondary: const Color(0xFFEBCB8B),
  );

  final theme = ThemeData.from(
    colorScheme: mode == ThemeMode.dark
        ? scheme
        : ColorScheme.fromSeed(seedColor: Colors.blueAccent),
    useMaterial3: true,
  ).copyWith(
    splashFactory: NoSplash.splashFactory,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintStyle: const TextStyle(height: 1),
      isDense: true,
    ),
  );
  if (mode == ThemeMode.dark) {
    return theme.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.3),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.disabled) ? null : scheme.secondary,
          ),
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF2E3440)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              width: 1,
              color: states.contains(WidgetState.disabled)
                  ? const Color.fromARGB(61, 195, 195, 195)
                  : scheme.secondary,
            ),
          ),
          mouseCursor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF2E3440),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(
            color: Color(0xFF434C5D),
            width: 1,
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: scheme.secondary,
        ),
        barrierColor: Colors.black.withOpacity(0.3),
      ),
    );
  }

  return theme;
}
