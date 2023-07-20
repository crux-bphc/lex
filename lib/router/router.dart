import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/screens/course.dart';
import 'package:ghotpromax/modules/cms/screens/home.dart';
import 'package:ghotpromax/modules/cms/screens/search.dart';
import 'package:ghotpromax/modules/cms/widgets/ensure_login.dart';
import 'package:ghotpromax/modules/impartus/screens/home.dart';
import 'package:ghotpromax/modules/impartus/screens/lectures.dart';
import 'package:ghotpromax/modules/impartus/widgets/ensure_login.dart';
import 'package:ghotpromax/modules/multipartus/screens/home.dart';
import 'package:ghotpromax/modules/settings/screens/home.dart';
import 'package:ghotpromax/router/scaffold.dart';
import 'package:go_router/go_router.dart';

final _cmsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cms');
final _impartusNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'impartus');
final _multipartusNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'multipartus',
);

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
          routes: [
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
              ],
            )
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _impartusNavigatorKey,
          routes: [
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
                    subjectId: state.pathParameters['subjectId']!,
                    sessionId: state.pathParameters['sessionId']!,
                  ),
                ),
              ],
            )
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _multipartusNavigatorKey,
          routes: [
            GoRoute(
              path: '/multipartus',
              builder: (context, state) => const MultipartusHomePage(),
            )
          ],
        )
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    )
  ],
);
