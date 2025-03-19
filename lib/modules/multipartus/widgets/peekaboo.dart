import 'package:flutter/material.dart';

class PeekaBoo extends StatelessWidget {
  const PeekaBoo({
    super.key,
    this.child,
    this.alignment = Alignment.center,
    this.curve = Curves.easeOutQuad,
  });

  final Widget? child;
  final Alignment alignment;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: alignment,
      curve: curve,
      duration: Durations.short3,
      child: AnimatedSwitcher(
        duration: Durations.short3,
        child: child != null ? child! : SizedBox(),
      ),
    );
  }
}
