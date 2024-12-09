// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CMSCourseContentImpl _$$CMSCourseContentImplFromJson(
        Map<String, dynamic> json) =>
    _$CMSCourseContentImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      modules: (json['modules'] as List<dynamic>?)
              ?.map((e) => CMSCourseModule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

_$CMSCourseModuleImpl _$$CMSCourseModuleImplFromJson(
        Map<String, dynamic> json) =>
    _$CMSCourseModuleImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      modname: json['modname'] as String,
      instance: (json['instance'] as num).toInt(),
      description: json['description'] as String?,
      contents: json['contents'] == null
          ? null
          : CMSCourseFile.fromJson(json['contents'] as Map<String, dynamic>),
    );

_$CMSCourseFileImpl _$$CMSCourseFileImplFromJson(Map<String, dynamic> json) =>
    _$CMSCourseFileImpl(
      filename: json['filename'] as String,
      fileurl: json['fileurl'] as String,
    );

_$CMSRegisteredCourseImpl _$$CMSRegisteredCourseImplFromJson(
        Map<String, dynamic> json) =>
    _$CMSRegisteredCourseImpl(
      id: (json['id'] as num).toInt(),
      displayname: json['displayname'] as String,
    );
