import 'package:freezed_annotation/freezed_annotation.dart';
part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class CMSUser with _$CMSUser {
  const factory CMSUser({
    required String username,
    required String firstname,
    required int userid,
  }) = _CMSUser;

  factory CMSUser.fromJson(Map<String, dynamic> json) =>
      _$CMSUserFromJson(json);
}
