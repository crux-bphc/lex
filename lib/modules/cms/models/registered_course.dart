import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html_unescape/html_unescape_small.dart';
part 'registered_course.freezed.dart';
part 'registered_course.g.dart';

final unescape = HtmlUnescape();

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
