import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/screens/home.dart';
import 'package:ghotpromax/modules/impartus/screens/home.dart';
import 'package:ghotpromax/modules/multipartus/screens/home.dart';
import 'package:ghotpromax/modules/settings/screens/home.dart';
import 'package:go_router/go_router.dart';

class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              onDestinationSelected: _goBranch,
              selectedIndex: navigationShell.currentIndex,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  label: Text('CMS'),
                  icon: Icon(Icons.library_books_outlined),
                  selectedIcon: Icon(Icons.library_books),
                ),
                NavigationRailDestination(
                  label: Text('Impartus'),
                  icon: Icon(Icons.smart_display_outlined),
                  selectedIcon: Icon(Icons.smart_display),
                ),
                NavigationRailDestination(
                  label: Text('Multipartus'),
                  icon: Icon(Icons.subscriptions_outlined),
                  selectedIcon: Icon(Icons.subscriptions),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        context.go('/settings');
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: navigationShell)
          ],
        ),
      ),
    );
  }
}

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
        return _DesktopScaffold(
          navigationShell: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _cmsNavigatorKey,
          routes: [
            GoRoute(
              path: '/cms',
              builder: (context, state) => const CMSHomePage(),
            )
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _impartusNavigatorKey,
          routes: [
            GoRoute(
              path: '/impartus',
              builder: (context, state) => const ImpartusHomePage(),
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
