import 'package:freezed_annotation/freezed_annotation.dart';
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

@freezed
class CMSCourseModule with _$CMSCourseModule {
  factory CMSCourseModule({
    required int id,
    required String name,
    required String modname,
  }) = _CMSCourseModule;

  factory CMSCourseModule.fromJson(Map<String, dynamic> json) =>
      _$CMSCourseModuleFromJson(json);
}
