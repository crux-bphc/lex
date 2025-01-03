import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/error.dart';
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
            _Body(body: body),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.body});

  final Widget body;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  StreamSubscription? _errorSub;
  String _previousError = '';

  @override
  void initState() {
    super.initState();

    _errorSub = GetIt.instance<ErrorService>().errorStream.listen((message) {
      if (!mounted || message == _previousError) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade50,
            ),
          ),
          elevation: 0,
          showCloseIcon: true,
          closeIconColor: Colors.red.shade50,
          backgroundColor: Colors.red.shade400,
          duration: Duration(seconds: 8),
          dismissDirection: DismissDirection.horizontal,
        ),
      );

      _previousError = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: widget.body);
  }

  @override
  void dispose() {
    super.dispose();

    _errorSub?.cancel();
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
    final isRegistered = GetIt.instance.isRegistered<BackButtonObserver>();
    return SizedBox.square(
      dimension: 60,
      child: Center(
        child: isRegistered
            ? Watch(
                (context) {
                  final backProvider = GetIt.instance<BackButtonObserver>();
                  final showBack = backProvider.showBackButton();

                  return const _CruxIcon()
                      .animate(target: showBack ? 1 : 0)
                      .fadeOut(duration: 160.ms, curve: Curves.easeOutCubic)
                      .slideX(
                        begin: 0,
                        end: -0.2,
                        duration: 180.ms,
                        curve: Curves.easeIn,
                      )
                      .swap(
                        duration: 180.ms,
                        builder: (_, __) =>
                            _BackButton(onPressed: backProvider.pop)
                                .animate()
                                .fadeIn(
                                  duration: 100.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .slideX(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 120.ms,
                                  curve: Curves.easeOutQuad,
                                ),
                      );
                },
              )
            : const _CruxIcon(),
      ),
    );
  }
}

class _CruxIcon extends StatelessWidget {
  const _CruxIcon();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AnimatedSwitcher(
      duration: kThemeChangeDuration,
      child: Image.asset(
        key: ValueKey(isDarkMode),
        isDarkMode ? "assets/crux.png" : "assets/cruxDark.png",
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      icon: const Icon(LucideIcons.arrow_left),
    );
  }
}
