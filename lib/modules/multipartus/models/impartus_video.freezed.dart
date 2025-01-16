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

ImpartusVideoData _$ImpartusVideoDataFromJson(Map<String, dynamic> json) {
  return _ImpartusVideoData.fromJson(json);
}

/// @nodoc
mixin _$ImpartusVideoData {
  int get ttid => throw _privateConstructorUsedError;
  int get videoId => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  @JsonKey(name: "seqNo")
  int get lectureNo => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
  DateTime get createdAt => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$ImpartusVideoDataImpl implements _ImpartusVideoData {
  const _$ImpartusVideoDataImpl(
      {required this.ttid,
      required this.videoId,
      required this.topic,
      @JsonKey(name: "seqNo") required this.lectureNo,
      @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
      required this.createdAt});

  factory _$ImpartusVideoDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImpartusVideoDataImplFromJson(json);

  @override
  final int ttid;
  @override
  final int videoId;
  @override
  final String topic;
  @override
  @JsonKey(name: "seqNo")
  final int lectureNo;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
  final DateTime createdAt;

  @override
  String toString() {
    return 'ImpartusVideoData(ttid: $ttid, videoId: $videoId, topic: $topic, lectureNo: $lectureNo, createdAt: $createdAt)';
  }
}

abstract class _ImpartusVideoData implements ImpartusVideoData {
  const factory _ImpartusVideoData(
      {required final int ttid,
      required final int videoId,
      required final String topic,
      @JsonKey(name: "seqNo") required final int lectureNo,
      @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
      required final DateTime createdAt}) = _$ImpartusVideoDataImpl;

  factory _ImpartusVideoData.fromJson(Map<String, dynamic> json) =
      _$ImpartusVideoDataImpl.fromJson;

  @override
  int get ttid;
  @override
  int get videoId;
  @override
  String get topic;
  @override
  @JsonKey(name: "seqNo")
  int get lectureNo;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, name: "startTime")
  DateTime get createdAt;
}
