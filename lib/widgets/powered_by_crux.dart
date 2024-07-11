import 'package:flutter/material.dart';

class PoweredByCrux extends StatelessWidget {
  const PoweredByCrux({
    super.key,
    required this.child,
    this.alignment = Alignment.centerRight,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        children: [
          child,
          Align(
            alignment: alignment,
            child: const Text(
              "Powered by cruX",
              style: TextStyle(
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
