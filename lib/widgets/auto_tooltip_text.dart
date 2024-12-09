import 'package:flutter/material.dart';

class AutoTooltipText extends StatelessWidget {
  const AutoTooltipText({
    super.key,
    required this.text,
    this.maxLines,
    this.overflow,
    String? tooltipText,
    this.style,
  }) : tooltipText = tooltipText ?? text;

  final String text;
  final String tooltipText;

  final TextStyle? style;

  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: "$text...", style: style);
        final painter = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: Directionality.of(context),
          textAlign: TextAlign.left,
        );

        painter.layout(maxWidth: constraints.maxWidth);

        final showTooltip = painter.didExceedMaxLines;

        painter.dispose();

        return Tooltip(
          message: showTooltip ? tooltipText : '',
          preferBelow: false,
          child: Text(
            text,
            overflow: overflow,
            maxLines: maxLines,
            style: style,
          ),
        );
      },
    );
  }
}
