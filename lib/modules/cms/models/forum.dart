import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lex/modules/cms/models/course.dart';
import 'package:html2md/html2md.dart' as html2md;
part 'forum.freezed.dart';
part 'forum.g.dart';

@Freezed(fromJson: true)
class CMSForumDiscussion with _$CMSForumDiscussion {
  const factory CMSForumDiscussion({
    required String name,
    required int discussion,
    required String message,
    required String userfullname,
    required int created,
    @Default([]) List<CMSCourseFile> attachments,
  }) = _CMSForumDiscussion;

  factory CMSForumDiscussion.fromJson(Map<String, dynamic> json) {
    json['message'] = html2md.convert(json['message'] as String);
    return _$CMSForumDiscussionFromJson(json);
  }
}
