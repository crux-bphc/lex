import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _navItems = [
  _NavItem('CMS', Icons.book_outlined),
  _NavItem('Multipartus', Icons.video_collection_outlined),
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
            SizedBox(
              width: 110,
              child: Material(
                elevation: 10,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const AspectRatio(
                        aspectRatio: 1,
                        child: Placeholder(
                          color: Color(0xFFEBCB8B),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      for (final (i, item) in _navItems.indexed)
                        _NavButton(
                          navItem: item,
                          onPressed: () => onDestinationSelected(i),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          radius: 16,
                          child: const Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _NavToolTip(
                        text: 'Settings',
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          iconSize: 32,
                          onPressed: () {
                            context.go('/settings');
                          },
                        ),
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
  const _NavItem(this.title, this.icon);
  final String title;
  final IconData icon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.navItem, required this.onPressed});

  final _NavItem navItem;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _NavToolTip(
        text: navItem.title,
        child: RawMaterialButton(
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Icon(
            navItem.icon,
            color: Theme.of(context).colorScheme.onBackground,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _NavToolTip extends StatefulWidget {
  const _NavToolTip({
    required this.child,
    required this.text,
    double? horizontalOffset,
    Duration? duration,
  })  : horizontalOffset = horizontalOffset ?? 50,
        duration = duration ?? const Duration(milliseconds: 100);

  @override
  State<_NavToolTip> createState() => _NavToolTipState();

  final Widget child;
  final String text;
  final double horizontalOffset;
  final Duration duration;
}

class _NavToolTipState extends State<_NavToolTip>
    with SingleTickerProviderStateMixin {
  final _controller = OverlayPortalController();

  late final _animation = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  late final _curvedAnimation = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeInCubic,
  );

  Widget _buildOverlay(BuildContext context) {
    // from Flutter Tooltip source code
    final overlayState = Overlay.of(context);
    final renderBox = this.context.findRenderObject()! as RenderBox;
    final Offset target = renderBox.localToGlobal(
      renderBox.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );

    // fade and fly in animation
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, child) => Positioned(
        top: target.dy - renderBox.size.height / 2,
        left: target.dx +
            widget.horizontalOffset -
            2 +
            2 * _curvedAnimation.value,
        child: Opacity(
          opacity: _curvedAnimation.value,
          child: child!,
        ),
      ),
      child: SizedBox(
        height: renderBox.size.height,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEBCB8B),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.background,
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _show() {
    _controller.show();
    _animation.forward();
  }

  void _hide() async {
    await _animation.reverse();
    _controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _show(),
      onExit: (event) => _hide(),
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: _buildOverlay,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _animation.dispose();

    super.dispose();
  }
}
