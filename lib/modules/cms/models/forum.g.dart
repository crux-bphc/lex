// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CMSForumDiscussionImpl _$$CMSForumDiscussionImplFromJson(
        Map<String, dynamic> json) =>
    _$CMSForumDiscussionImpl(
      name: json['name'] as String,
      discussion: (json['discussion'] as num).toInt(),
      message: json['message'] as String,
      userfullname: json['userfullname'] as String,
      created: (json['created'] as num).toInt(),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => CMSCourseFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
