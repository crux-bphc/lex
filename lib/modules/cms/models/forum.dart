import 'package:freezed_annotation/freezed_annotation.dart';
part 'forum.freezed.dart';
part 'forum.g.dart';

@freezed
class CMSForumDiscussion with _$CMSForumDiscussion {
  const factory CMSForumDiscussion({
    required String name,
    required String message,
    required String userfullname,
  }) = _CMSForumDiscussion;

  factory CMSForumDiscussion.fromJson(Map<String, dynamic> json) =>
      _$CMSForumDiscussionFromJson(json);
}
