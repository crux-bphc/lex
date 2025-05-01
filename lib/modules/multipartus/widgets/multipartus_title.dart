import 'package:flutter/material.dart';

class MultipartusTitle extends StatelessWidget {
  const MultipartusTitle({
    super.key,
    this.fontSize = 50,
  });

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: fontSize / 8,
      height: 1,
    );
    final child = Text.rich(
      TextSpan(
        text: 'MULTI',
        children: [
          WidgetSpan(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PARTUS',
                  style: style.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'β',
                    style: TextStyle(
                      // fontFeatures: [FontFeature.superscripts()],
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize / 3.125,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
        ],
      ),
      textWidthBasis: TextWidthBasis.longestLine,
      style: style,
    );

    return child;
  }
}
