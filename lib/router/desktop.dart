import 'package:flutter/material.dart';
import 'package:lex/router/theme_switcher.dart';
import 'package:go_router/go_router.dart';

const _navItems = [
  _NavItem(
    icon: Icons.library_books_outlined,
    selectedIcon: Icons.library_books,
    label: 'CMS',
  ),
  _NavItem(
    icon: Icons.smart_display_outlined,
    selectedIcon: Icons.smart_display,
    label: 'Multipartus',
  ),
];

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
              minWidth: 100,
              backgroundColor: Theme.of(context).colorScheme.background,
              elevation: 6,
              leading: const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 40),
                child: Placeholder(
                  fallbackHeight: 60,
                  fallbackWidth: 60,
                ),
              ),
              destinations: [
                for (final item in _navItems)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                  ),
              ],
              trailing: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ThemeSwitcher(
                        iconSize: 30,
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        iconSize: 30,
                        onPressed: () {
                          context.go('/settings');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon, selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
