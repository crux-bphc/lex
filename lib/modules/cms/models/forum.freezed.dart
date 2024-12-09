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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CMSForumDiscussion _$CMSForumDiscussionFromJson(Map<String, dynamic> json) {
  return _CMSForumDiscussion.fromJson(json);
}

/// @nodoc
mixin _$CMSForumDiscussion {
  String get name => throw _privateConstructorUsedError;
  int get discussion => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get userfullname => throw _privateConstructorUsedError;
  int get created => throw _privateConstructorUsedError;
  List<CMSCourseFile> get attachments => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$CMSForumDiscussionImpl implements _CMSForumDiscussion {
  const _$CMSForumDiscussionImpl(
      {required this.name,
      required this.discussion,
      required this.message,
      required this.userfullname,
      required this.created,
      final List<CMSCourseFile> attachments = const []})
      : _attachments = attachments;

  factory _$CMSForumDiscussionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CMSForumDiscussionImplFromJson(json);

  @override
  final String name;
  @override
  final int discussion;
  @override
  final String message;
  @override
  final String userfullname;
  @override
  final int created;
  final List<CMSCourseFile> _attachments;
  @override
  @JsonKey()
  List<CMSCourseFile> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'CMSForumDiscussion(name: $name, discussion: $discussion, message: $message, userfullname: $userfullname, created: $created, attachments: $attachments)';
  }
}

abstract class _CMSForumDiscussion implements CMSForumDiscussion {
  const factory _CMSForumDiscussion(
      {required final String name,
      required final int discussion,
      required final String message,
      required final String userfullname,
      required final int created,
      final List<CMSCourseFile> attachments}) = _$CMSForumDiscussionImpl;

  factory _CMSForumDiscussion.fromJson(Map<String, dynamic> json) =
      _$CMSForumDiscussionImpl.fromJson;

  @override
  String get name;
  @override
  int get discussion;
  @override
  String get message;
  @override
  String get userfullname;
  @override
  int get created;
  @override
  List<CMSCourseFile> get attachments;
}
