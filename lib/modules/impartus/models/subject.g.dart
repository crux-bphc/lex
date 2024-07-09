// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImpartusSubjectImpl _$$ImpartusSubjectImplFromJson(
        Map<String, dynamic> json) =>
    _$ImpartusSubjectImpl(
      subjectId: (json['subjectId'] as num).toInt(),
      subjectName: json['subjectName'] as String,
      sessionId: (json['sessionId'] as num).toInt(),
      professorName: json['professorName'] as String,
      videoCount: (json['videoCount'] as num).toInt(),
    );

_$ImpartusLectureImpl _$$ImpartusLectureImplFromJson(
        Map<String, dynamic> json) =>
    _$ImpartusLectureImpl(
      videoId: (json['videoId'] as num).toInt(),
      ttid: (json['ttid'] as num).toInt(),
      topic: json['topic'] as String,
      professorName: json['professorName'] as String,
    );
