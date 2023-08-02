// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forum.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CMSForumDiscussion _$CMSForumDiscussionFromJson(Map<String, dynamic> json) {
  return _CMSForumDiscussion.fromJson(json);
}

/// @nodoc
mixin _$CMSForumDiscussion {
  String get name => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get userfullname => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_CMSForumDiscussion implements _CMSForumDiscussion {
  const _$_CMSForumDiscussion(
      {required this.name, required this.message, required this.userfullname});

  factory _$_CMSForumDiscussion.fromJson(Map<String, dynamic> json) =>
      _$$_CMSForumDiscussionFromJson(json);

  @override
  final String name;
  @override
  final String message;
  @override
  final String userfullname;

  @override
  String toString() {
    return 'CMSForumDiscussion(name: $name, message: $message, userfullname: $userfullname)';
  }
}

abstract class _CMSForumDiscussion implements CMSForumDiscussion {
  const factory _CMSForumDiscussion(
      {required final String name,
      required final String message,
      required final String userfullname}) = _$_CMSForumDiscussion;

  factory _CMSForumDiscussion.fromJson(Map<String, dynamic> json) =
      _$_CMSForumDiscussion.fromJson;

  @override
  String get name;
  @override
  String get message;
  @override
  String get userfullname;
}
