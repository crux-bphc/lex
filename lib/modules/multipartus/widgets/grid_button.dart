import 'package:flutter/material.dart';

class GridButton extends StatelessWidget {
  const GridButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.all(20),
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final void Function() onPressed;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 0,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
