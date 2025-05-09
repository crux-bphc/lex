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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MULTI',
          style: style,
        ),
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
              fontWeight: FontWeight.bold,
              fontSize: fontSize / 3.125,
              height: 0,
            ),
          ),
        ),
      ],
    );
  }
}
