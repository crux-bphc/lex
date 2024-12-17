// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecture_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImpartusSectionDataImpl _$$ImpartusSectionDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ImpartusSectionDataImpl(
      impartusSession: (json['impartus_session'] as num).toInt(),
      impartusSubject: (json['impartus_subject'] as num).toInt(),
      section: (json['section'] as num).toInt(),
      professor: json['professor'] as String,
    );
