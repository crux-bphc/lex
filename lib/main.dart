import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/auth/keycloak_auth.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/providers/error.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/router/router.dart';
import 'package:lex/theme.dart';
import 'package:media_kit/media_kit.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  await _prelaunchTasks();

  runApp(const MyApp());
}

Future<void> _prelaunchTasks() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  usePathUrlStrategy();

  // does nothing on non web platforms
  if (kIsWeb) BrowserContextMenu.disableContextMenu();

  await initializeDateFormatting();

  SignalsObserver.instance = null;

  final getIt = GetIt.instance;

  getIt.registerSingleton<BackButtonObserver>(backButtonObserver);

  getIt.registerSingletonAsync<LocalStorage>(
    () async {
      final storage = LocalStorage();
      await storage.initialize();
      return storage;
    },
    dispose: (storage) => storage.dispose(),
  );
  await getIt.isReady<LocalStorage>();

  getIt.registerSingleton<ErrorService>(ErrorService());

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

  void Function()? _dispose;

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
    _dispose = isLoggedIn.subscribe((_) {
      router.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: "Lex",
      themeMode: getIt<LocalStorage>().preferences.themeMode.watch(context),
      theme: buildTheme(ThemeMode.light),
      darkTheme: buildTheme(ThemeMode.dark),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _dispose?.call();
  }
}
