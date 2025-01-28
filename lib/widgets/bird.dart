import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ErrorBird extends StatelessWidget {
  const ErrorBird({super.key, this.message, this.size = 100});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.bird,
            size: size,
          ),
          const SizedBox(height: 10),
          if (message != null) Text(message!),
        ],
      ),
    );
  }
}
