// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'impartus_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImpartusVideoDataImpl _$$ImpartusVideoDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ImpartusVideoDataImpl(
      ttid: (json['ttid'] as num).toInt(),
      videoId: (json['videoId'] as num).toInt(),
      topic: json['topic'] as String,
      lectureNo: (json['seqNo'] as num).toInt(),
      createdAt: _dateTimeFromJson(json['startTime'] as String),
    );
