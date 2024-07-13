import 'package:flutter/material.dart';

class GridButton extends StatelessWidget {
  const GridButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 0,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: child,
    );
  }
}
