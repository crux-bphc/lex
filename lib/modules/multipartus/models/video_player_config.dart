import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:signals/signals_flutter.dart';

part 'video_player_config.freezed.dart';

@Freezed(equal: true)
class VideoPlayerConfigData with _$VideoPlayerConfigData {
  const factory VideoPlayerConfigData({
    ImpartusVideo? previousVideo,
    ImpartusVideo? nextVideo,
    ImpartusVideo? currentVideo,
    double? playbackSpeed,
    double? playbackVolume,
  }) = _VideoPlayerConfigData;
}

class VideoPlayerConfig extends FlutterSignal<VideoPlayerConfigData> {
  VideoPlayerConfig([super.value = const VideoPlayerConfigData()]);
}
