// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'impartus_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ImpartusVideo _$ImpartusVideoFromJson(Map<String, dynamic> json) {
  return _ImpartusVideo.fromJson(json);
}

/// @nodoc
mixin _$ImpartusVideo {
  int get ttid => throw _privateConstructorUsedError;
  int get videoId => throw _privateConstructorUsedError;
  @JsonKey(name: "topic")
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: "professorName")
  String get professor => throw _privateConstructorUsedError;
  @JsonKey(name: "seqNo")
  int get lectureNo => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get subjectId => throw _privateConstructorUsedError;
  int get sessionId => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$ImpartusVideoImpl implements _ImpartusVideo {
  const _$ImpartusVideoImpl(
      {required this.ttid,
      required this.videoId,
      @JsonKey(name: "topic") required this.title,
      @JsonKey(name: "professorName") required this.professor,
      @JsonKey(name: "seqNo") required this.lectureNo,
      @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
      required this.createdAt,
      required this.subjectId,
      required this.sessionId});

  factory _$ImpartusVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImpartusVideoImplFromJson(json);

  @override
  final int ttid;
  @override
  final int videoId;
  @override
  @JsonKey(name: "topic")
  final String title;
  @override
  @JsonKey(name: "professorName")
  final String professor;
  @override
  @JsonKey(name: "seqNo")
  final int lectureNo;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
  final DateTime createdAt;
  @override
  final int subjectId;
  @override
  final int sessionId;

  @override
  String toString() {
    return 'ImpartusVideo(ttid: $ttid, videoId: $videoId, title: $title, professor: $professor, lectureNo: $lectureNo, createdAt: $createdAt, subjectId: $subjectId, sessionId: $sessionId)';
  }
}

abstract class _ImpartusVideo implements ImpartusVideo {
  const factory _ImpartusVideo(
      {required final int ttid,
      required final int videoId,
      @JsonKey(name: "topic") required final String title,
      @JsonKey(name: "professorName") required final String professor,
      @JsonKey(name: "seqNo") required final int lectureNo,
      @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
      required final DateTime createdAt,
      required final int subjectId,
      required final int sessionId}) = _$ImpartusVideoImpl;

  factory _ImpartusVideo.fromJson(Map<String, dynamic> json) =
      _$ImpartusVideoImpl.fromJson;

  @override
  int get ttid;
  @override
  int get videoId;
  @override
  @JsonKey(name: "topic")
  String get title;
  @override
  @JsonKey(name: "professorName")
  String get professor;
  @override
  @JsonKey(name: "seqNo")
  int get lectureNo;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
  DateTime get createdAt;
  @override
  int get subjectId;
  @override
  int get sessionId;
}
