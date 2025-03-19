import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class SharedAxisSwitcher extends StatefulWidget {
  const SharedAxisSwitcher({
    super.key,
    required this.child,
    required this.value,
    this.duration = Durations.medium2,
  });

  final Widget child;
  final int value;
  final Duration duration;

  @override
  State<SharedAxisSwitcher> createState() => _SharedAxisSwitcherState();
}

class _SharedAxisSwitcherState extends State<SharedAxisSwitcher> {
  bool _reverse = false;

  @override
  void didUpdateWidget(covariant SharedAxisSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value > widget.value) {
      _reverse = true;
    } else {
      _reverse = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: widget.duration,
      reverse: _reverse,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
