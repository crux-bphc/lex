import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/screens/course.dart';
import 'package:lex/modules/multipartus/screens/home.dart';
import 'package:lex/modules/multipartus/screens/video.dart';
import 'package:lex/modules/multipartus/widgets/login_gate.dart';
import 'package:lex/modules/settings/screens/home.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/router/scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/auth/auth_page.dart';
import 'package:signals/signals_flutter.dart';

final _cmsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cms');
final _multipartusNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'multipartus',
);

final backButtonObserver = BackButtonObserver();

const _defaultInitialLocation = '/multipartus';

// TODO: store this in local storage
String? _initialLocation;

final _cmsRoutes = [
  GoRoute(
    path: '/cms',
    builder: (context, state) => const Scaffold(
      body: Center(
        child: Text("There's nothing to see here"),
      ),
    ),
  ),
  // ShellRoute(
  //   builder: (builder, state, child) => CMSAuthenticate(
  //     child: child,
  //   ),
  //   routes: [
  //     GoRoute(
  //       path: '/cms',
  //       builder: (context, state) => const CMSHomePage(),
  //     ),
  //     GoRoute(
  //       path: '/cms/course/:id',
  //       builder: (context, state) {
  //         return CMSCoursePage(id: state.pathParameters['id']!);
  //       },
  //     ),
  //     GoRoute(
  //       path: '/cms/search',
  //       builder: (context, state) => const CMSSearchPage(),
  //     ),
  //     GoRoute(
  //       path: '/cms/forum/:id',
  //       builder: (context, state) {
  //         return CMSForumPage(id: state.pathParameters['id']!);
  //       },
  //     ),
  //   ],
  // ),
];

final router = GoRouter(
  redirect: (context, state) {
    // capture the first location the user tried reaching
    // so that after loading the user can be redirected back
    _initialLocation ??= state.uri.toString();

    final getIt = GetIt.instance;

    // still loading
    if (!getIt.allReadySync()) {
      return '/';
    }
    final isLoggedIn = getIt<AuthProvider>().isLoggedIn();

    // logged out
    if (!isLoggedIn) {
      return '/';
    }

    // done logging in
    if (isLoggedIn && state.matchedLocation == '/') {
      return _initialLocation != '/'
          ? _initialLocation!
          : _defaultInitialLocation;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShellScaffold(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _cmsNavigatorKey,
          routes: _cmsRoutes,
        ),
        StatefulShellBranch(
          navigatorKey: _multipartusNavigatorKey,
          routes: [
            ShellRoute(
              observers: [backButtonObserver],
              builder: (context, state, child) =>
                  MultipartusLoginGate(child: child),
              routes: [
                GoRoute(
                  path: '/multipartus',
                  builder: (context, state) => const MultipartusHomePage(),
                  routes: [
                    GoRoute(
                      path: 'courses/:department/:code',
                      builder: (context, state) {
                        final department = state.pathParameters['department']!
                            .replaceAll(',', '/');
                        final code = state.pathParameters['code']!;
                        return MultipartusCoursePage(
                          department: department,
                          subjectCode: code,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'watch/:ttid',
                          builder: (context, state) {
                            final department = state
                                .pathParameters['department']!
                                .replaceAll(',', '/');
                            final code = state.pathParameters['code']!;
                            final timestamp = state.uri.queryParameters['t'];

                            return MultipartusVideoPage(
                              department: department,
                              subjectCode: code,
                              ttid: state.pathParameters['ttid']!,
                              startTimestamp: int.tryParse(timestamp ?? ''),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class BackButtonObserver extends NavigatorObserver {
  final showBackButton = signal(false);

  void _updateSignal() {
    showBackButton.value = navigator?.canPop() ?? false;
  }

  void pop() {
    if (untracked(() => showBackButton())) {
      navigator?.pop();
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _updateSignal();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _updateSignal();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _updateSignal();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _updateSignal();
  }
}
