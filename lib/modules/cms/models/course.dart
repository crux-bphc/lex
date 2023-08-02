import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghotpromax/logger.dart';
part 'course.freezed.dart';
part 'course.g.dart';

@freezed
class CMSCourseContent with _$CMSCourseContent {
  const factory CMSCourseContent({
    required int id,
    required String name,
    @Default([]) List<CMSCourseModule> modules,
  }) = _CMSCourseContent;

  factory CMSCourseContent.fromJson(Map<String, dynamic> json) =>
      _$CMSCourseContentFromJson(json);
}

@Freezed(fromJson: true)
class CMSCourseModule with _$CMSCourseModule {
  factory CMSCourseModule({
    required int id,
    required String name,
    required String modname,
    required int instance,
    CMSCourseFile? contents,
  }) = _CMSCourseModule;

  factory CMSCourseModule.fromJson(Map<String, dynamic> json) {
    if (json['contents'] != null) {
      final files = json['contents'] as List<dynamic>;
      if (files.length != 1) {
        logger.e("Expected course module to only have one file attached.");
      }
      json['contents'] = files[0];
    }
    return _$CMSCourseModuleFromJson(json);
  }
}

@freezed
class CMSCourseFile with _$CMSCourseFile {
  const factory CMSCourseFile({
    required String filename,
    required String fileurl,
  }) = _CMSCourseFile;

  factory CMSCourseFile.fromJson(Map<String, dynamic> json) =>
      _$CMSCourseFileFromJson(json);
}

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
