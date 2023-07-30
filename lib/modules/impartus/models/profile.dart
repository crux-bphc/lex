import 'package:freezed_annotation/freezed_annotation.dart';
part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class ImpartusProfile with _$ImpartusProfile {
  const factory ImpartusProfile({
    required int userId,
    required String fname,
    required int sessionId,
    required String batchName,
    required String batchId,
  }) = _ImpartusProfile;

  factory ImpartusProfile.fromJson(Map<String, dynamic> json) =>
      _$ImpartusProfileFromJson(json);
}
