// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CMSCourseContent _$$_CMSCourseContentFromJson(Map<String, dynamic> json) =>
    _$_CMSCourseContent(
      id: json['id'] as int,
      name: json['name'] as String,
      modules: (json['modules'] as List<dynamic>?)
              ?.map((e) => CMSCourseModule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

_$_CMSCourseModule _$$_CMSCourseModuleFromJson(Map<String, dynamic> json) =>
    _$_CMSCourseModule(
      id: json['id'] as int,
      name: json['name'] as String,
      modname: json['modname'] as String,
    );