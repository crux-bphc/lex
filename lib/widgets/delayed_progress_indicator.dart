import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DelayedProgressIndicator extends StatelessWidget {
  const DelayedProgressIndicator({
    super.key,
    this.duration = const Duration(seconds: 1),
    this.size = 30,
  });

  final Duration duration;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: FutureBuilder(
        future: Future.delayed(duration),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
                ? const CircularProgressIndicator.adaptive(
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                  ).animate().fadeIn(duration: 400.ms)
                : Container(),
      ),
    );
  }
}
