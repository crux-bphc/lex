import 'package:freezed_annotation/freezed_annotation.dart';

part 'lecture_section.freezed.dart';
part 'lecture_section.g.dart';

@freezed
class ImpartusSection with _$ImpartusSection {
  const factory ImpartusSection({
    @JsonKey(name: 'impartus_session') required int impartusSession,
    @JsonKey(name: 'impartus_subject') required int impartusSubject,
    required String section,
    required String professor,
  }) = _ImpartusSection;

  factory ImpartusSection.fromJson(Map<String, Object?> json) =>
      _$ImpartusSectionFromJson(json);
}
