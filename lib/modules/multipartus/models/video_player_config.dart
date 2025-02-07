import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';

part 'video_player_config.freezed.dart';

@Freezed(equal: true)
class VideoPlayerConfigData with _$VideoPlayerConfigData {
  const factory VideoPlayerConfigData({
    ImpartusVideo? previousVideo,
    ImpartusVideo? nextVideo,
  }) = _VideoPlayerConfigData;
}

class VideoPlayerConfig extends InheritedWidget {
  final VideoPlayerConfigData data;

  const VideoPlayerConfig({
    super.key,
    required super.child,
    required this.data,
  });

  @override
  bool updateShouldNotify(covariant VideoPlayerConfig oldWidget) =>
      oldWidget.data != data;

  static VideoPlayerConfigData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<VideoPlayerConfig>()
        ?.data;
  }
}
