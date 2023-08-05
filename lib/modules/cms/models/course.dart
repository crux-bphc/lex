import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghotpromax/utils/logger.dart';
import 'package:ghotpromax/utils/unescape.dart';
import 'package:html2md/html2md.dart' as html2md;
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
    String? description,
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

    json['name'] = unescape.convert(json['name'] as String);

    if (json['description'] != null) {
      json['description'] = html2md.convert(json['description'] as String);
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

@Freezed(fromJson: true)
class CMSRegisteredCourse with _$CMSRegisteredCourse {
  const factory CMSRegisteredCourse({
    required int id,
    required String displayname,
  }) = _CMSRegisteredCourse;

  factory CMSRegisteredCourse.fromJson(Map<String, dynamic> json) {
    json['displayname'] = unescape.convert(json['displayname'] as String);
    return _$CMSRegisteredCourseFromJson(json);
  }
}
