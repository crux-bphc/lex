import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/widgets/video_player/controller.dart';
import 'package:media_kit_video/media_kit_video.dart';

const controlsIconSize = 24.0;

Duration getViewAwareDuration(Duration totalDuration) =>
    totalDuration == Duration.zero
        ? const Duration(minutes: 59, seconds: 59)
        : totalDuration * 0.5;

MultiViewVideoController getController(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.controller
        as MultiViewVideoController;

class VideoNavigateNotification extends Notification {
  final NavigationType navigationType;

  VideoNavigateNotification(this.navigationType);
}

enum NavigationType {
  next,
  previous;

  int get offset => switch (this) {
        NavigationType.next => 1,
        NavigationType.previous => -1,
      };
}
