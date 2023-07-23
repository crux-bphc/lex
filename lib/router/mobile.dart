import 'package:flutter/material.dart';
import 'package:ghotpromax/router/theme_switcher.dart';
import 'package:go_router/go_router.dart';

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({
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
      appBar: AppBar(
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: SafeArea(child: body),
      drawer: NavigationDrawer(
        onDestinationSelected: onDestinationSelected,
        selectedIndex: selectedIndex,
        children: const [
          SizedBox(height: 18.0),
          NavigationDrawerDestination(
            label: Text('CMS'),
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
          ),
          NavigationDrawerDestination(
            label: Text('Impartus'),
            icon: Icon(Icons.smart_display_outlined),
            selectedIcon: Icon(Icons.smart_display),
          ),
          NavigationDrawerDestination(
            label: Text('Multipartus'),
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions),
          ),
          NavigationDrawerDestination(
            label: Text('Resources'),
            icon: Icon(Icons.link_outlined),
            selectedIcon: Icon(Icons.link),
          ),
        ],
      ),
    );
  }
}
