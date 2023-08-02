// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registered_course.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CMSRegisteredCourse _$CMSRegisteredCourseFromJson(Map<String, dynamic> json) {
  return _CMSRegisteredCourse.fromJson(json);
}

/// @nodoc
mixin _$CMSRegisteredCourse {
  int get id => throw _privateConstructorUsedError;
  String get displayname => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_CMSRegisteredCourse implements _CMSRegisteredCourse {
  const _$_CMSRegisteredCourse({required this.id, required this.displayname});

  factory _$_CMSRegisteredCourse.fromJson(Map<String, dynamic> json) =>
      _$$_CMSRegisteredCourseFromJson(json);

  @override
  final int id;
  @override
  final String displayname;

  @override
  String toString() {
    return 'CMSRegisteredCourse(id: $id, displayname: $displayname)';
  }
}

abstract class _CMSRegisteredCourse implements CMSRegisteredCourse {
  const factory _CMSRegisteredCourse(
      {required final int id,
      required final String displayname}) = _$_CMSRegisteredCourse;

  factory _CMSRegisteredCourse.fromJson(Map<String, dynamic> json) =
      _$_CMSRegisteredCourse.fromJson;

  @override
  int get id;
  @override
  String get displayname;
}
