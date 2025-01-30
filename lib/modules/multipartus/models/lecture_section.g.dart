// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImpartusSectionImpl _$$ImpartusSectionImplFromJson(
        Map<String, dynamic> json) =>
    _$ImpartusSectionImpl(
      impartusSession: (json['impartus_session'] as num).toInt(),
      impartusSubject: (json['impartus_subject'] as num).toInt(),
      section: json['section'] as String,
      professor: json['professor'] as String,
    );
