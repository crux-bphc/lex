import 'package:freezed_annotation/freezed_annotation.dart';

part 'impartus_video.freezed.dart';
part 'impartus_video.g.dart';

@freezed
class ImpartusVideoData with _$ImpartusVideoData {
  const factory ImpartusVideoData({
    required int ttid,
    required String topic,
    @JsonKey(name: "seqNo") required int lectureNo,
    @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
    required DateTime createdAt,
  }) = _ImpartusVideoData;

  factory ImpartusVideoData.fromJson(Map<String, Object?> json) =>
      _$ImpartusVideoDataFromJson(json);
}

DateTime _dateTimeFromJson(String text) {
  return DateTime.parse(text);
}
