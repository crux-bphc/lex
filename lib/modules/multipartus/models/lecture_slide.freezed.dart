// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lecture_slide.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LectureSlide _$LectureSlideFromJson(Map<String, dynamic> json) {
  return _LectureSlide.fromJson(json);
}

/// @nodoc
mixin _$LectureSlide {
  int get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  int get start => throw _privateConstructorUsedError;
  int get end => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$LectureSlideImpl implements _LectureSlide {
  const _$LectureSlideImpl(
      {required this.id,
      required this.url,
      required this.start,
      required this.end});

  factory _$LectureSlideImpl.fromJson(Map<String, dynamic> json) =>
      _$$LectureSlideImplFromJson(json);

  @override
  final int id;
  @override
  final String url;
  @override
  final int start;
  @override
  final int end;

  @override
  String toString() {
    return 'LectureSlide(id: $id, url: $url, start: $start, end: $end)';
  }
}

abstract class _LectureSlide implements LectureSlide {
  const factory _LectureSlide(
      {required final int id,
      required final String url,
      required final int start,
      required final int end}) = _$LectureSlideImpl;

  factory _LectureSlide.fromJson(Map<String, dynamic> json) =
      _$LectureSlideImpl.fromJson;

  @override
  int get id;
  @override
  String get url;
  @override
  int get start;
  @override
  int get end;
}
