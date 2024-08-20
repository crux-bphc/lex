import 'package:flutter/material.dart';
import 'package:lex/router/theme_switcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

const _navItems = [
  _NavItem(
    icon: LucideIcons.book,
    label: 'CMS',
  ),
  _NavItem(
    icon: LucideIcons.video,
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
            Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 0,
                  ),
                ],
              ),
              margin: const EdgeInsets.only(right: 2),
              child: NavigationRail(
                onDestinationSelected: onDestinationSelected,
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                minWidth: 100,
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 6,
                leading: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 40),
                  child: Image.asset((Theme.of(context).brightness == Brightness.dark) ? "assets/crux.png" : "assets/cruxDark.png", height: 60, width: 60,),
                ),
                destinations: [
                  for (final item in _navItems)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
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
                        const ThemeSwitcher(),
                        const SizedBox(height: 2),
                        IconButton(
                          icon: const Icon(LucideIcons.settings),
                          onPressed: () {
                            context.push('/settings');
                          },
                        ),
                      ],
                    ),
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
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}
