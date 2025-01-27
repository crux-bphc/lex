import 'package:freezed_annotation/freezed_annotation.dart';

part 'lecture_slide.freezed.dart';
part 'lecture_slide.g.dart';

@freezed
class LectureSlide with _$LectureSlide {
  const factory LectureSlide({
    required int id,
    required String url,
    required int start,
    required int end,
  }) = _LectureSlide;

  factory LectureSlide.fromJson(Map<String, Object?> json) =>
      _$LectureSlideFromJson(json);
}
