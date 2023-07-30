import 'package:freezed_annotation/freezed_annotation.dart';
part 'subject.freezed.dart';
part 'subject.g.dart';

@freezed
class ImpartusSubject with _$ImpartusSubject {
  const factory ImpartusSubject({
    required int subjectId,
    required String subjectName,
    required int sessionId,
    required String professorName,
    required int videoCount,
  }) = _ImpartusSubject;

  factory ImpartusSubject.fromJson(Map<String, dynamic> json) =>
      _$ImpartusSubjectFromJson(json);
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
