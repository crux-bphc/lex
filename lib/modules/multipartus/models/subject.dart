import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:lex/modules/multipartus/models/surrealql_list_id.dart';

part 'subject.freezed.dart';
part 'subject.g.dart';

@freezed
class Subject with _$Subject {
  const Subject._();

  const factory Subject({
    required SubjectId id,
    required String name,
  }) = _Subject;

  /// Returns the full course code in the form
  /// `{department} {code}`.
  ///
  /// Example: `CHEM F111`.
  String get prettyCode => '${id.department} ${id.code}';

  factory Subject.fromJson(Map<String, Object?> json) =>
      _$SubjectFromJson(json);
}

class SubjectId extends SurrealQlListId<String> {
  late final String department = items[0];
  late final String code = items[1];

  late final departmentUrl = department.replaceAll('/', ',');

  SubjectId(String department, String code) : super([department, code]);
  SubjectId.parse(String text) : super(_parser(text));

  static final _parser = surrealQlListIdParser(
    'subject',
    (text) => text.length > 2 ? text.substring(1, text.length - 1) : text,
  );

  factory SubjectId.fromJson(String id) => SubjectId.parse(id);

  @override
  String toString() => '$department $code';

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(covariant SubjectId other) {
    return other.toString() == toString();
  }
}
