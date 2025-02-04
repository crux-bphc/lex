import 'package:freezed_annotation/freezed_annotation.dart';

part 'impartus_video.freezed.dart';
part 'impartus_video.g.dart';

@freezed
class ImpartusVideo with _$ImpartusVideo {
  const factory ImpartusVideo({
    required int ttid,
    required int videoId,
    @JsonKey(name: "topic") required String title,
    @JsonKey(name: "professorName") required String professor,
    @JsonKey(name: "seqNo") required int lectureNo,
    @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
    required DateTime createdAt,

    /// The ID of the subject provided by Impartus
    @JsonKey(name: "subjectId") required int impartusSubjectId,

    /// The session ID of the video provided by Impartus
    required int sessionId,
  }) = _ImpartusVideo;

  factory ImpartusVideo.fromJson(Map<String, Object?> json) =>
      _$ImpartusVideoFromJson(json);
}

DateTime _dateTimeFromJson(String text) {
  return DateTime.parse(text);
}
