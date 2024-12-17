import 'package:freezed_annotation/freezed_annotation.dart';

part 'lecture_section.freezed.dart';
part 'lecture_section.g.dart';

@freezed
class ImpartusSectionData with _$ImpartusSectionData {
  const factory ImpartusSectionData({
    @JsonKey(name: 'impartus_session') required int impartusSession,
    @JsonKey(name: 'impartus_subject') required int impartusSubject,
    required int section,
    required String professor,
  }) = _ImpartusSectionData;

  factory ImpartusSectionData.fromJson(Map<String, Object?> json) =>
      _$ImpartusSectionDataFromJson(json);
}
