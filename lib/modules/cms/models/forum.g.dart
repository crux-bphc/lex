// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CMSForumDiscussion _$$_CMSForumDiscussionFromJson(
        Map<String, dynamic> json) =>
    _$_CMSForumDiscussion(
      name: json['name'] as String,
      discussion: json['discussion'] as int,
      message: json['message'] as String,
      userfullname: json['userfullname'] as String,
      created: json['created'] as int,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => CMSCourseFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
