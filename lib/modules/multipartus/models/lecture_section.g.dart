// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LectureSectionImpl _$$LectureSectionImplFromJson(Map<String, dynamic> json) =>
    _$LectureSectionImpl(
      id: LectureId.fromJson(json['id'] as String),
      section: (json['section'] as num).toInt(),
      professor: json['professor'] as String,
    );
