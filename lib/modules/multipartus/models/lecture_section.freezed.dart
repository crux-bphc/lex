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

ImpartusSectionData _$ImpartusSectionDataFromJson(Map<String, dynamic> json) {
  return _ImpartusSectionData.fromJson(json);
}

/// @nodoc
mixin _$ImpartusSectionData {
  @JsonKey(name: 'impartus_session')
  int get impartusSession => throw _privateConstructorUsedError;
  @JsonKey(name: 'impartus_subject')
  int get impartusSubject => throw _privateConstructorUsedError;
  int get section => throw _privateConstructorUsedError;
  String get professor => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$ImpartusSectionDataImpl implements _ImpartusSectionData {
  const _$ImpartusSectionDataImpl(
      {@JsonKey(name: 'impartus_session') required this.impartusSession,
      @JsonKey(name: 'impartus_subject') required this.impartusSubject,
      required this.section,
      required this.professor});

  factory _$ImpartusSectionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImpartusSectionDataImplFromJson(json);

  @override
  @JsonKey(name: 'impartus_session')
  final int impartusSession;
  @override
  @JsonKey(name: 'impartus_subject')
  final int impartusSubject;
  @override
  final int section;
  @override
  final String professor;

  @override
  String toString() {
    return 'ImpartusSectionData(impartusSession: $impartusSession, impartusSubject: $impartusSubject, section: $section, professor: $professor)';
  }
}

abstract class _ImpartusSectionData implements ImpartusSectionData {
  const factory _ImpartusSectionData(
      {@JsonKey(name: 'impartus_session') required final int impartusSession,
      @JsonKey(name: 'impartus_subject') required final int impartusSubject,
      required final int section,
      required final String professor}) = _$ImpartusSectionDataImpl;

  factory _ImpartusSectionData.fromJson(Map<String, dynamic> json) =
      _$ImpartusSectionDataImpl.fromJson;

  @override
  @JsonKey(name: 'impartus_session')
  int get impartusSession;
  @override
  @JsonKey(name: 'impartus_subject')
  int get impartusSubject;
  @override
  int get section;
  @override
  String get professor;
}
