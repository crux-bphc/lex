import 'package:flutter/material.dart';
import 'package:lex/modules/cms/screens/course.dart';
import 'package:lex/modules/cms/screens/forum.dart';
import 'package:lex/modules/cms/screens/home.dart';
import 'package:lex/modules/cms/screens/search.dart';
import 'package:lex/modules/cms/widgets/ensure_login.dart';
import 'package:lex/modules/impartus/screens/home.dart';
import 'package:lex/modules/impartus/screens/lecture.dart';
import 'package:lex/modules/impartus/screens/lectures.dart';
import 'package:lex/modules/impartus/widgets/ensure_login.dart';
import 'package:lex/modules/multipartus/screens/home.dart';
import 'package:lex/modules/resources/screens/home.dart';
import 'package:lex/modules/settings/screens/home.dart';
import 'package:lex/router/scaffold.dart';
import 'package:go_router/go_router.dart';

final _cmsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cms');
final _impartusNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'impartus');
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

final _impartusRoutes = [
  ShellRoute(
    builder: (builder, state, child) => ImpartusAuthenticate(
      child: child,
    ),
    routes: [
      GoRoute(
        path: '/impartus',
        builder: (context, state) => const ImpartusHomePage(),
      ),
      GoRoute(
        path: '/impartus/lectures/:subjectId/:sessionId',
        builder: (context, state) => ImpartusLecturesPage(
          subjectId: int.parse(state.pathParameters['subjectId']!),
          sessionId: int.parse(state.pathParameters['sessionId']!),
        ),
      ),
      GoRoute(
        path: '/impartus/lecture',
        builder: (context, state) => const ImpartusLecturePage(),
      ),
    ],
  ),
];

final router = GoRouter(
  initialLocation: '/cms',
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
          navigatorKey: _impartusNavigatorKey,
          routes: _impartusRoutes,
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/resources',
              builder: (context, state) => const ResourcesHomePage(),
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
