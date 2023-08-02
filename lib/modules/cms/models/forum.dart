import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';
part 'forum.freezed.dart';
part 'forum.g.dart';

@freezed
class CMSForumDiscussion with _$CMSForumDiscussion {
  const factory CMSForumDiscussion({
    required String name,
    required int discussion,
    required String message,
    required String userfullname,
    required int created,
    @Default([]) List<CMSCourseFile> attachments,
  }) = _CMSForumDiscussion;

  factory CMSForumDiscussion.fromJson(Map<String, dynamic> json) =>
      _$CMSForumDiscussionFromJson(json);
}
