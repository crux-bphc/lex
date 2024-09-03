// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lecture_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LectureSection _$LectureSectionFromJson(Map<String, dynamic> json) {
  return _LectureSection.fromJson(json);
}

/// @nodoc
mixin _$LectureSection {
  LectureId get id => throw _privateConstructorUsedError;
  int get section => throw _privateConstructorUsedError;
  String get professor => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$LectureSectionImpl implements _LectureSection {
  const _$LectureSectionImpl(
      {required this.id, required this.section, required this.professor});

  factory _$LectureSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LectureSectionImplFromJson(json);

  @override
  final LectureId id;
  @override
  final int section;
  @override
  final String professor;

  @override
  String toString() {
    return 'LectureSection(id: $id, section: $section, professor: $professor)';
  }
}

abstract class _LectureSection implements LectureSection {
  const factory _LectureSection(
      {required final LectureId id,
      required final int section,
      required final String professor}) = _$LectureSectionImpl;

  factory _LectureSection.fromJson(Map<String, dynamic> json) =
      _$LectureSectionImpl.fromJson;

  @override
  LectureId get id;
  @override
  int get section;
  @override
  String get professor;
}
