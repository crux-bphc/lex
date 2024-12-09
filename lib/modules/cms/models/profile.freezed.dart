// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CMSUser _$CMSUserFromJson(Map<String, dynamic> json) {
  return _CMSUser.fromJson(json);
}

/// @nodoc
mixin _$CMSUser {
  String get username => throw _privateConstructorUsedError;
  String get firstname => throw _privateConstructorUsedError;
  int get userid => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$CMSUserImpl implements _CMSUser {
  const _$CMSUserImpl(
      {required this.username, required this.firstname, required this.userid});

  factory _$CMSUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$CMSUserImplFromJson(json);

  @override
  final String username;
  @override
  final String firstname;
  @override
  final int userid;

  @override
  String toString() {
    return 'CMSUser(username: $username, firstname: $firstname, userid: $userid)';
  }
}

abstract class _CMSUser implements CMSUser {
  const factory _CMSUser(
      {required final String username,
      required final String firstname,
      required final int userid}) = _$CMSUserImpl;

  factory _CMSUser.fromJson(Map<String, dynamic> json) = _$CMSUserImpl.fromJson;

  @override
  String get username;
  @override
  String get firstname;
  @override
  int get userid;
}
