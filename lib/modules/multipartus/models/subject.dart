import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'subject.freezed.dart';
part 'subject.g.dart';

@Freezed(copyWith: true)
class Subject with _$Subject {
  const Subject._();

  factory Subject({
    required String name,
    required String department,
    required String code,
    @JsonKey(defaultValue: false) required bool isPinned,
  }) = _Subject;

  /// Returns the full course code in the form
  /// `{department} {code}`.
  ///
  /// Example: `CHEM F111`.
  String get prettyCode => '$department $code';

  String get departmentUrl => department.replaceAll('/', ',');

  SubjectId get subjectId => (department: department, code: code);

  factory Subject.fromJson(Map<String, Object?> json) =>
      _$SubjectFromJson(json);
}

typedef SubjectId = ({String department, String code});
