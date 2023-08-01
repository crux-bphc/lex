// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subject.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ImpartusSubject _$ImpartusSubjectFromJson(Map<String, dynamic> json) {
  return _ImpartusSubject.fromJson(json);
}

/// @nodoc
mixin _$ImpartusSubject {
  int get subjectId => throw _privateConstructorUsedError;
  String get subjectName => throw _privateConstructorUsedError;
  int get sessionId => throw _privateConstructorUsedError;
  String get professorName => throw _privateConstructorUsedError;
  int get videoCount => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_ImpartusSubject implements _ImpartusSubject {
  const _$_ImpartusSubject(
      {required this.subjectId,
      required this.subjectName,
      required this.sessionId,
      required this.professorName,
      required this.videoCount});

  factory _$_ImpartusSubject.fromJson(Map<String, dynamic> json) =>
      _$$_ImpartusSubjectFromJson(json);

  @override
  final int subjectId;
  @override
  final String subjectName;
  @override
  final int sessionId;
  @override
  final String professorName;
  @override
  final int videoCount;

  @override
  String toString() {
    return 'ImpartusSubject(subjectId: $subjectId, subjectName: $subjectName, sessionId: $sessionId, professorName: $professorName, videoCount: $videoCount)';
  }
}

abstract class _ImpartusSubject implements ImpartusSubject {
  const factory _ImpartusSubject(
      {required final int subjectId,
      required final String subjectName,
      required final int sessionId,
      required final String professorName,
      required final int videoCount}) = _$_ImpartusSubject;

  factory _ImpartusSubject.fromJson(Map<String, dynamic> json) =
      _$_ImpartusSubject.fromJson;

  @override
  int get subjectId;
  @override
  String get subjectName;
  @override
  int get sessionId;
  @override
  String get professorName;
  @override
  int get videoCount;
}

ImpartusLecture _$ImpartusLectureFromJson(Map<String, dynamic> json) {
  return _ImpartusLecture.fromJson(json);
}

/// @nodoc
mixin _$ImpartusLecture {
  int get videoId => throw _privateConstructorUsedError;
  int get ttid => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  String get professorName => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_ImpartusLecture implements _ImpartusLecture {
  const _$_ImpartusLecture(
      {required this.videoId,
      required this.ttid,
      required this.topic,
      required this.professorName});

  factory _$_ImpartusLecture.fromJson(Map<String, dynamic> json) =>
      _$$_ImpartusLectureFromJson(json);

  @override
  final int videoId;
  @override
  final int ttid;
  @override
  final String topic;
  @override
  final String professorName;

  @override
  String toString() {
    return 'ImpartusLecture(videoId: $videoId, ttid: $ttid, topic: $topic, professorName: $professorName)';
  }
}

abstract class _ImpartusLecture implements ImpartusLecture {
  const factory _ImpartusLecture(
      {required final int videoId,
      required final int ttid,
      required final String topic,
      required final String professorName}) = _$_ImpartusLecture;

  factory _ImpartusLecture.fromJson(Map<String, dynamic> json) =
      _$_ImpartusLecture.fromJson;

  @override
  int get videoId;
  @override
  int get ttid;
  @override
  String get topic;
  @override
  String get professorName;
}
