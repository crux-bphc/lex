import 'package:flutter/material.dart';
import 'package:lex/widgets/error_bird.dart';

class ErrorBirdContainer extends StatelessWidget {
  const ErrorBirdContainer(this.error, {super.key});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: ErrorBird(
        message: error.toString(),
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}
