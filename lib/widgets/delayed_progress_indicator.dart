import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DelayedProgressIndicator extends StatelessWidget {
  const DelayedProgressIndicator({
    super.key,
    this.duration = Durations.extralong4,
    this.size = 30,
  });

  final Duration duration;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: const CircularProgressIndicator.adaptive(
          strokeWidth: 3,
          strokeCap: StrokeCap.round,
        ).animate(delay: duration).fade(duration: Durations.medium4),
      ),
    );
  }
}
