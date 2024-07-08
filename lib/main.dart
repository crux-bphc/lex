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
