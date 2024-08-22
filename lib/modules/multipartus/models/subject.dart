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

  /// Returns the full course code in the form
  /// `{department} {code}`.
  ///
  /// Example: `CHEM F111`.
  String get prettyCode => '${id.department} ${id.code}';

  factory Subject.fromJson(Map<String, Object?> json) =>
      _$SubjectFromJson(json);
}

final _regexp = RegExp(r"^subject:\['(.+)', '(.+)'\]$");

class SubjectId {
  final String department;
  final String code;

  const SubjectId(this.department, this.code);

  String get routeId => '$department-$code';
  String get backendId => "subject:['$department', '$code']";

  /// For parsing subject IDs that look like `subject:['CHEM', 'F111']`.
  factory SubjectId.fromBackendId(String id) {
    final [department, code] = _regexp.firstMatch(id.trim())!.groups([1, 2]);
    return SubjectId(department!, code!);
  }

  /// For parsing subject IDs that look like `CHEM-F111`.
  factory SubjectId.fromRouteId(String id) {
    final parts = id.split('-');
    return SubjectId(parts[0], parts[1]);
  }

  factory SubjectId.fromJson(String id) => SubjectId.fromBackendId(id);

  @override
  int get hashCode => routeId.hashCode;

  @override
  bool operator ==(covariant SubjectId other) {
    return routeId == other.routeId;
  }
}
