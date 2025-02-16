import 'package:flutter/material.dart';

class LectureTitle extends StatelessWidget {
  const LectureTitle({
    super.key,
    required this.lectureNo,
    required this.title,
    this.lectureNoColor,
    this.titleColor,
    this.maxLines = 2,
    this.showShadows = false,
  });

  final String lectureNo, title;
  final Color? lectureNoColor;
  final Color? titleColor;
  final double fontSize = 32;
  final bool showShadows;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.7),
      offset: Offset(1.4, 1.4),
      blurRadius: 3,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: titleColor ?? Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [if (showShadows) shadow],
          ),
          child: Text(
            lectureNo,
            style: TextStyle(
              color: lectureNoColor ?? Theme.of(context).colorScheme.surface,
              fontSize: fontSize,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor ?? Theme.of(context).colorScheme.primary,
              fontSize: fontSize,
              shadows: [if (showShadows) shadow],
            ),
          ),
        ),
      ],
    );
  }

  static InlineSpan buildSpan({
    required String lectureNo,
    required String title,
    required Color lectureNoColor,
    required Color titleColor,
    double? fontSize,
    double? borderRadius,
  }) {
    return TextSpan(
      children: [
        WidgetSpan(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: titleColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
            ),
            child: Text(lectureNo),
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
        ),
        TextSpan(
          text: title,
          style: TextStyle(
            fontSize: fontSize,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
