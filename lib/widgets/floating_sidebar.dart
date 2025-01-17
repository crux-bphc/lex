import 'package:flutter/material.dart';

class FloatingSidebar extends StatelessWidget {
  const FloatingSidebar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
