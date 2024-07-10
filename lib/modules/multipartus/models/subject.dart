import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'subject.freezed.dart';
part 'subject.g.dart';

@freezed
class Subject with _$Subject {
  const Subject._();

  const factory Subject({
    required SubjectId id,
    required String name,
  }) = _Subject;

  String get department => id.department;
  String get code => id.code;
  String get fullCode => '$department $code';

  factory Subject.fromJson(Map<String, Object?> json) =>
      _$SubjectFromJson(json);
}

final _regexp = RegExp(r"^subject:\['(.+)', '(.+)'\]$");

class SubjectId {
  final String department;
  final String code;

  const SubjectId(this.department, this.code);

  factory SubjectId.fromJson(String id) {
    final [department, code] = _regexp.firstMatch(id.trim())!.groups([1, 2]);
    return SubjectId(department!, code!);
  }
}
