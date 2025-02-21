import 'package:flutter/material.dart';
import 'package:lex/router/desktop.dart';
import 'package:lex/router/mobile.dart';
import 'package:go_router/go_router.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return PlatformIsMobile(
          isMobile: isMobile,
          child: Builder(
            builder: (context) {
              return PlatformIsMobile.of(context)
                  ? MobileScaffold(
                      body: navigationShell,
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _goBranch,
                    )
                  : DesktopScaffold(
                      body: navigationShell,
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _goBranch,
                    );
            },
          ),
        );
      }),
    );
  }
}

class PlatformIsMobile extends InheritedWidget {
  final bool isMobile;

  const PlatformIsMobile(
      {super.key, required super.child, required this.isMobile});

  @override
  bool updateShouldNotify(covariant PlatformIsMobile oldWidget) =>
      oldWidget.isMobile != isMobile;

  static bool? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PlatformIsMobile>()
        ?.isMobile;
  }

  static bool of(BuildContext context) {
    final platformType = maybeOf(context);
    assert(platformType != null, 'PlatformType not found in context');

    return platformType!;
  }
}
