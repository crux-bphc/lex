import 'package:freezed_annotation/freezed_annotation.dart';

part 'impartus_video.freezed.dart';
part 'impartus_video.g.dart';

@freezed
class ImpartusVideo with _$ImpartusVideo {
  const factory ImpartusVideo({
    required int ttid,
    required String topic,
    @JsonKey(name: "seqNo") required int lectureNo,
    @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
    required DateTime createdAt,
  }) = _ImpartusVideo;

  factory ImpartusVideo.fromJson(Map<String, Object?> json) =>
      _$ImpartusVideoFromJson(json);
}

DateTime _dateTimeFromJson(String text) {
  return DateTime.parse(text);
}
