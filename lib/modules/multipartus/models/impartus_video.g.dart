// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'impartus_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImpartusVideoImpl _$$ImpartusVideoImplFromJson(Map<String, dynamic> json) =>
    _$ImpartusVideoImpl(
      ttid: (json['ttid'] as num).toInt(),
      topic: json['topic'] as String,
      lectureNo: (json['seqNo'] as num).toInt(),
      createdAt: _dateTimeFromJson(json['startTime'] as String),
    );
