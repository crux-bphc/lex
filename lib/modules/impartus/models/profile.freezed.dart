// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ImpartusProfile _$ImpartusProfileFromJson(Map<String, dynamic> json) {
  return _ImpartusProfile.fromJson(json);
}

/// @nodoc
mixin _$ImpartusProfile {
  int get userId => throw _privateConstructorUsedError;
  String get fname => throw _privateConstructorUsedError;
  int get sessionId => throw _privateConstructorUsedError;
  String get batchName => throw _privateConstructorUsedError;
  String get batchId => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_ImpartusProfile implements _ImpartusProfile {
  const _$_ImpartusProfile(
      {required this.userId,
      required this.fname,
      required this.sessionId,
      required this.batchName,
      required this.batchId});

  factory _$_ImpartusProfile.fromJson(Map<String, dynamic> json) =>
      _$$_ImpartusProfileFromJson(json);

  @override
  final int userId;
  @override
  final String fname;
  @override
  final int sessionId;
  @override
  final String batchName;
  @override
  final String batchId;

  @override
  String toString() {
    return 'ImpartusProfile(userId: $userId, fname: $fname, sessionId: $sessionId, batchName: $batchName, batchId: $batchId)';
  }
}

abstract class _ImpartusProfile implements ImpartusProfile {
  const factory _ImpartusProfile(
      {required final int userId,
      required final String fname,
      required final int sessionId,
      required final String batchName,
      required final String batchId}) = _$_ImpartusProfile;

  factory _ImpartusProfile.fromJson(Map<String, dynamic> json) =
      _$_ImpartusProfile.fromJson;

  @override
  int get userId;
  @override
  String get fname;
  @override
  int get sessionId;
  @override
  String get batchName;
  @override
  String get batchId;
}
