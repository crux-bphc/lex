// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ImpartusCourse _$$_ImpartusCourseFromJson(Map<String, dynamic> json) =>
    _$_ImpartusCourse(
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String,
      sessionId: json['sessionId'] as int,
      professorName: json['professorName'] as String,
      videoCount: json['videoCount'] as int,
    );

_$_ImpartusLecture _$$_ImpartusLectureFromJson(Map<String, dynamic> json) =>
    _$_ImpartusLecture(
      videoId: json['videoId'] as int,
      ttid: json['ttid'] as int,
      topic: json['topic'] as String,
      professorName: json['professorName'] as String,
    );
