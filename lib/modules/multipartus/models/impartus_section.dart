import 'package:freezed_annotation/freezed_annotation.dart';

part 'impartus_section.freezed.dart';
part 'impartus_section.g.dart';

@Freezed(equal: true)
class ImpartusSection with _$ImpartusSection {
  const factory ImpartusSection({
    @JsonKey(name: 'impartus_session') required int impartusSession,
    @JsonKey(name: 'impartus_subject') required int impartusSubject,

    /// eg. L1, T3, P2
    required String section,
    required String professor,
  }) = _ImpartusSection;

  factory ImpartusSection.fromJson(Map<String, Object?> json) =>
      _$ImpartusSectionFromJson(json);
}
