import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ErrorBird extends StatelessWidget {
  const ErrorBird({
    super.key,
    this.message,
    this.size = 100,
    this.foregroundColor,
  });

  final String? message;
  final double size;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bird,
            size: size,
            color: foregroundColor,
          ),
          const SizedBox(height: 10),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
