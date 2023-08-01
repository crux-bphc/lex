// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ImpartusSubject _$$_ImpartusSubjectFromJson(Map<String, dynamic> json) =>
    _$_ImpartusSubject(
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
