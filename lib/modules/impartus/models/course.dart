import 'package:freezed_annotation/freezed_annotation.dart';
part 'course.freezed.dart';
part 'course.g.dart';

@freezed
class ImpartusCourse with _$ImpartusCourse {
  const factory ImpartusCourse({
    required int subjectId,
    required String subjectName,
    required int sessionId,
    required String professorName,
    required int videoCount,
  }) = _ImpartusCourse;

  factory ImpartusCourse.fromJson(Map<String, dynamic> json) =>
      _$ImpartusCourseFromJson(json);
}

@freezed
class ImpartusLecture with _$ImpartusLecture {
  const factory ImpartusLecture({
    required int videoId,
    required int ttid,
    required String topic,
    required String professorName,
  }) = _ImpartusLecture;

  factory ImpartusLecture.fromJson(Map<String, dynamic> json) =>
      _$ImpartusLectureFromJson(json);
}
