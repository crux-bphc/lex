import 'package:flutter/material.dart';
import 'package:ghotpromax/router/theme_switcher.dart';
import 'package:go_router/go_router.dart';

class DesktopScaffold extends StatelessWidget {
  const DesktopScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              onDestinationSelected: onDestinationSelected,
              selectedIndex: selectedIndex,
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
                NavigationRailDestination(
                  label: Text('Resources'),
                  icon: Icon(Icons.link_outlined),
                  selectedIcon: Icon(Icons.link),
                ),
              ],
              trailing: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ThemeSwitcher(),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          context.go('/settings');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: body)
          ],
        ),
      ),
    );
  }
}
