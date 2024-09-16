import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/router/router.dart';
import 'package:lex/router/theme_switcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:signals/signals_flutter.dart';

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
                leading: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 40),
                  child: CruxBackButton(),
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

class CruxBackButton extends StatelessWidget {
  const CruxBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) {
        final backProvider = GetIt.instance<BackButtonObserver>();
        final showBack = backProvider.showBackButton();

        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return SizedBox.square(
          dimension: 60,
          child: Center(
            child: showBack
                ? IconButton(
                    onPressed: backProvider.pop,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    icon: const Icon(LucideIcons.arrow_left),
                  )
                : AnimatedSwitcher(
                    duration: kThemeChangeDuration,
                    child: Image.asset(
                      key: ValueKey(isDarkMode),
                      isDarkMode ? "assets/crux.png" : "assets/cruxDark.png",
                    ),
                  ),
          ),
        );
      },
    );
  }
}
