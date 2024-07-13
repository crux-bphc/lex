import 'package:freezed_annotation/freezed_annotation.dart';

part 'lecture_section.freezed.dart';
part 'lecture_section.g.dart';

@freezed
class LectureSection with _$LectureSection {
  const factory LectureSection({
    required String id,
    required int section,
    required String professor,
  }) = _LectureSection;

  factory LectureSection.fromJson(Map<String, Object?> json) =>
      _$LectureSectionFromJson(json);
}
