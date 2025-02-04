// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'impartus_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImpartusVideoImpl _$$ImpartusVideoImplFromJson(Map<String, dynamic> json) =>
    _$ImpartusVideoImpl(
      ttid: (json['ttid'] as num).toInt(),
      videoId: (json['videoId'] as num).toInt(),
      title: json['topic'] as String,
      professor: json['professorName'] as String,
      lectureNo: (json['seqNo'] as num).toInt(),
      createdAt: _dateTimeFromJson(json['startTime'] as String),
      impartusSubjectId: (json['subjectId'] as num).toInt(),
      sessionId: (json['sessionId'] as num).toInt(),
    );
