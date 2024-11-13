// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LectureSectionImpl _$$LectureSectionImplFromJson(Map<String, dynamic> json) =>
    _$LectureSectionImpl(
      impartusSession: (json['impartus_session'] as num).toInt(),
      impartusSubject: (json['impartus_subject'] as num).toInt(),
      section: (json['section'] as num).toInt(),
      professor: json['professor'] as String,
    );
