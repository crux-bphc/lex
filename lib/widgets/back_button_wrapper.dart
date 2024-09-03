import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class BackButtonWrapper extends StatelessWidget {
  const BackButtonWrapper({
    super.key,
    this.gap = 27,
    this.onPressed,
    required this.child,
  });

  final double gap;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 40 + gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40 + gap,
            child: Padding(
              padding: EdgeInsets.only(right: gap),
              child: IconButton(
                onPressed: onPressed ?? Navigator.of(context).pop,
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                icon: const Icon(LucideIcons.arrow_left),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
