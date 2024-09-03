import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/cms/screens/course.dart';
import 'package:lex/modules/cms/screens/forum.dart';
import 'package:lex/modules/cms/screens/home.dart';
import 'package:lex/modules/cms/screens/search.dart';
import 'package:lex/modules/cms/widgets/ensure_login.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/screens/course.dart';
import 'package:lex/modules/multipartus/screens/home.dart';
import 'package:lex/modules/multipartus/widgets/login_gate.dart';
import 'package:lex/modules/settings/screens/home.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/router/scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/auth/auth_page.dart';

final _cmsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cms');
final _multipartusNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'multipartus',
);

const _defaultInitialLocation = '/multipartus';

// TODO: store this in local storage
String? _initialLocation;

final _cmsRoutes = [
  ShellRoute(
    builder: (builder, state, child) => CMSAuthenticate(
      child: child,
    ),
    routes: [
      GoRoute(
        path: '/cms',
        builder: (context, state) => const CMSHomePage(),
      ),
      GoRoute(
        path: '/cms/course/:id',
        builder: (context, state) {
          return CMSCoursePage(id: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/cms/search',
        builder: (context, state) => const CMSSearchPage(),
      ),
      GoRoute(
        path: '/cms/forum/:id',
        builder: (context, state) {
          return CMSForumPage(id: state.pathParameters['id']!);
        },
      ),
    ],
  ),
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
              builder: (context, state, child) =>
                  MultipartusLoginGate(child: child),
              routes: [
                GoRoute(
                  path: '/multipartus',
                  builder: (context, state) => const MultipartusHomePage(),
                  routes: [
                    GoRoute(
                      path: 'courses/:id',
                      builder: (context, state) => MultipartusCoursePage(
                        subjectId:
                            SubjectId.fromRouteId(state.pathParameters['id']!),
                      ),
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
