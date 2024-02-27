import 'package:flutter/material.dart';
import 'package:lex/modules/cms/screens/course.dart';
import 'package:lex/modules/cms/screens/forum.dart';
import 'package:lex/modules/cms/screens/home.dart';
import 'package:lex/modules/cms/screens/search.dart';
import 'package:lex/modules/cms/widgets/ensure_login.dart';
import 'package:lex/modules/multipartus/screens/home.dart';
import 'package:lex/modules/settings/screens/home.dart';
import 'package:lex/router/scaffold.dart';
import 'package:go_router/go_router.dart';

final _cmsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cms');
final _multipartusNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'multipartus',
);

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
  initialLocation: '/multipartus',
  routes: [
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
            GoRoute(
              path: '/multipartus',
              builder: (context, state) => const MultipartusHomePage(),
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
