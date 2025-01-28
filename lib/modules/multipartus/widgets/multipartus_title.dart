import 'package:flutter/material.dart';

class MultipartusTitle extends StatelessWidget {
  const MultipartusTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final child = Text.rich(
      TextSpan(
        text: 'MULTI',
        children: [
          TextSpan(
            text: 'PARTUS',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ],
      ),
      textWidthBasis: TextWidthBasis.longestLine,
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w700,
        letterSpacing: 8,
        height: 1,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        Text(
          'β',
          style: TextStyle(
            fontFeatures: [FontFeature.superscripts()],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
