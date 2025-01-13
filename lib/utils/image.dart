import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Widget Function(BuildContext, Widget, int?, bool) fadeInImageFrameBuilder({
  Duration duration = Durations.medium4,
}) {
  return (
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return child
        .animate(target: frame != null ? 1 : 0)
        .fadeIn(duration: duration);
  };
}

const _thumbnailBase = String.fromEnvironment("THUMBNAIL_URL");

String getThumbnailUrl(String ttid) {
  return "$_thumbnailBase/$ttid.jpg";
}
