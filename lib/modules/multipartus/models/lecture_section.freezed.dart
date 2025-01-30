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

ImpartusSection _$ImpartusSectionFromJson(Map<String, dynamic> json) {
  return _ImpartusSection.fromJson(json);
}

/// @nodoc
mixin _$ImpartusSection {
  @JsonKey(name: 'impartus_session')
  int get impartusSession => throw _privateConstructorUsedError;
  @JsonKey(name: 'impartus_subject')
  int get impartusSubject => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  String get professor => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$ImpartusSectionImpl implements _ImpartusSection {
  const _$ImpartusSectionImpl(
      {@JsonKey(name: 'impartus_session') required this.impartusSession,
      @JsonKey(name: 'impartus_subject') required this.impartusSubject,
      required this.section,
      required this.professor});

  factory _$ImpartusSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImpartusSectionImplFromJson(json);

  @override
  @JsonKey(name: 'impartus_session')
  final int impartusSession;
  @override
  @JsonKey(name: 'impartus_subject')
  final int impartusSubject;
  @override
  final String section;
  @override
  final String professor;

  @override
  String toString() {
    return 'ImpartusSection(impartusSession: $impartusSession, impartusSubject: $impartusSubject, section: $section, professor: $professor)';
  }
}

abstract class _ImpartusSection implements ImpartusSection {
  const factory _ImpartusSection(
      {@JsonKey(name: 'impartus_session') required final int impartusSession,
      @JsonKey(name: 'impartus_subject') required final int impartusSubject,
      required final String section,
      required final String professor}) = _$ImpartusSectionImpl;

  factory _ImpartusSection.fromJson(Map<String, dynamic> json) =
      _$ImpartusSectionImpl.fromJson;

  @override
  @JsonKey(name: 'impartus_session')
  int get impartusSession;
  @override
  @JsonKey(name: 'impartus_subject')
  int get impartusSubject;
  @override
  String get section;
  @override
  String get professor;
}
