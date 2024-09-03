import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lex/modules/multipartus/models/surrealql_list_id.dart';

part 'lecture_section.freezed.dart';
part 'lecture_section.g.dart';

@freezed
class LectureSection with _$LectureSection {
  const factory LectureSection({
    required LectureId id,
    required int section,
    required String professor,
  }) = _LectureSection;

  factory LectureSection.fromJson(Map<String, Object?> json) =>
      _$LectureSectionFromJson(json);
}

class LectureId extends SurrealQlListId<int> {
  late final sessionId = items[0];
  late final subjectId = items[1];

  LectureId.parse(String text) : super(_parser(text));

  static final _parser = surrealQlListIdParser(
    'lecture',
    (text) => int.parse(text),
  );

  factory LectureId.fromJson(String id) => LectureId.parse(id);
}
