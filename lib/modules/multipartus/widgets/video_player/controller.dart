import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/widgets/video_player/utils.dart';
import 'package:lex/utils/extensions.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';

class MultiViewVideoController extends VideoController {
  final GlobalKey<VideoState> videoWidgetKey;

  MultiViewVideoController({
    required Player player,
    required this.videoWidgetKey,
  }) : super(player) {
    player.stream.position.listen((event) {
      if (_continuousSeekPosition == null) {
        _positionStreamController.add(getViewAwarePosition(event));
      }
    });
  }

  late double _beforeMutingVolume = player.state.volume;

  Duration? _continuousSeekPosition;

  Duration get totalDuration => player.state.duration;

  late final viewAwareBufferFractionStream = player.stream.buffer.map(
    (e) => getViewAwareFraction(e).clampNaN(0, 1),
  );

  late final viewAwareDurationStream =
      player.stream.duration.map(getViewAwareDuration);

  final _positionStreamController = StreamController<Duration>.broadcast();

  late final viewAwarePositionFractionStream = _positionStreamController.stream
      .map((e) => getViewAwareFraction(e).clampNaN(0, 1));

  late final viewAwarePositionStream = _positionStreamController.stream;

  bool isView2(Duration position) =>
      position > getViewAwareDuration(totalDuration);

  Duration getViewAwarePosition(Duration position) => isView2(position)
      ? position - getViewAwareDuration(totalDuration)
      : position;

  double getViewAwareFraction(Duration position) =>
      getViewAwarePosition(position).inMilliseconds /
      getViewAwareDuration(totalDuration).inMilliseconds;

  void switchViews() {
    final total = player.state.duration.inMilliseconds;
    final totalHalf = total ~/ 2;
    final current = player.state.position.inMilliseconds;
    final newPos =
        (current > totalHalf ? current - totalHalf : current + totalHalf)
            .clamp(0, total);

    player.seek(Duration(milliseconds: newPos));
  }

  void viewAwareFractionalSeek(double positionFraction) {
    final actual = getViewAwareDuration(totalDuration);

    player.seek(
      isView2(player.state.position)
          ? actual + actual * positionFraction
          : actual * positionFraction,
    );
  }

  void viewAwareContinuousSeekBy(Duration duration) {
    _continuousSeekPosition ??= getViewAwarePosition(player.state.position);

    _continuousSeekPosition = (_continuousSeekPosition! + duration)
        .clamp(Duration.zero, getViewAwareDuration(totalDuration));

    player.seek(
      isView2(player.state.position)
          ? getViewAwareDuration(totalDuration) + _continuousSeekPosition!
          : _continuousSeekPosition!,
    );

    _positionStreamController.add(_continuousSeekPosition!);
  }

  void stopContinuousSeek() {
    if (_continuousSeekPosition != null) {
      player.seek(
        isView2(player.state.position)
            ? getViewAwareDuration(totalDuration) + _continuousSeekPosition!
            : _continuousSeekPosition!,
      );
    }

    _continuousSeekPosition = null;
  }

  void increaseRate({double by = 0.25, double clamp = 3.0}) {
    player.setRate((player.state.rate + by).clamp(0.25, clamp));
  }

  void decreaseRate({double by = 0.25, double clamp = 3.0}) {
    player.setRate((player.state.rate - by).clamp(0.25, clamp));
  }

  void toggleMute() {
    if (player.state.volume == 0) {
      player.setVolume(_beforeMutingVolume == 0 ? 100 : _beforeMutingVolume);
    } else {
      _beforeMutingVolume = player.state.volume;
      player.setVolume(0);
    }
  }

  void exitFullscreen() {
    defaultExitNativeFullscreen();
    videoWidgetKey.currentState?.exitFullscreen();
  }

  void enterFullscreen() {
    defaultEnterNativeFullscreen();
    videoWidgetKey.currentState?.enterFullscreen();
  }

  void toggleFullscreen() {
    if (videoWidgetKey.currentState?.isFullscreen() ?? false) {
      exitFullscreen();
    } else {
      enterFullscreen();
    }
  }

  void increaseVolume() {
    player.setVolume((player.state.volume + 10).clamp(0, 100));
  }

  void decreaseVolume() {
    player.setVolume((player.state.volume - 10).clamp(0, 100));
  }

  void navigateVideo(BuildContext context, NavigationType type) {
    late final isFullscreen =
        (videoWidgetKey.currentState?.isFullscreen() ?? false);

    if (kIsWeb && isFullscreen) {
      exitFullscreen();
    }

    VideoNavigateNotification(type).dispatch(context);
  }
}
