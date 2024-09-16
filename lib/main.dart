import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/auth/keycloak_auth.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/providers/preferences.dart';
import 'package:lex/router/router.dart';
import 'package:lex/theme.dart';
import 'package:media_kit/media_kit.dart';
import 'package:signals/signals_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await initializeDateFormatting();

  _setupGetIt();

  runApp(const MyApp());
}

void _setupGetIt() {
  SignalsObserver.instance = null;

  final getIt = GetIt.instance;
  getIt.registerSingleton<Preferences>(
    Preferences()..initialize(),
    dispose: (prefs) => prefs.dispose(),
  );

  getIt.registerSingleton<BackButtonObserver>(backButtonObserver);

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
    dispose: (backend) => backend.dispose(),
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
    isLoggedIn.subscribe((_) {
      router.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: const ValueKey("Loaded"),
      routerConfig: router,
      themeMode: getIt<Preferences>().themeMode.watch(context),
      theme: buildTheme(ThemeMode.light),
      darkTheme: buildTheme(ThemeMode.dark),
    );
  }
}
