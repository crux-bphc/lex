// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CMSCourseContent _$CMSCourseContentFromJson(Map<String, dynamic> json) {
  return _CMSCourseContent.fromJson(json);
}

/// @nodoc
mixin _$CMSCourseContent {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<CMSCourseModule> get modules => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_CMSCourseContent implements _CMSCourseContent {
  const _$_CMSCourseContent(
      {required this.id,
      required this.name,
      final List<CMSCourseModule> modules = const []})
      : _modules = modules;

  factory _$_CMSCourseContent.fromJson(Map<String, dynamic> json) =>
      _$$_CMSCourseContentFromJson(json);

  @override
  final int id;
  @override
  final String name;
  final List<CMSCourseModule> _modules;
  @override
  @JsonKey()
  List<CMSCourseModule> get modules {
    if (_modules is EqualUnmodifiableListView) return _modules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modules);
  }

  @override
  String toString() {
    return 'CMSCourseContent(id: $id, name: $name, modules: $modules)';
  }
}

abstract class _CMSCourseContent implements CMSCourseContent {
  const factory _CMSCourseContent(
      {required final int id,
      required final String name,
      final List<CMSCourseModule> modules}) = _$_CMSCourseContent;

  factory _CMSCourseContent.fromJson(Map<String, dynamic> json) =
      _$_CMSCourseContent.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  List<CMSCourseModule> get modules;
}

CMSCourseModule _$CMSCourseModuleFromJson(Map<String, dynamic> json) {
  return _CMSCourseModule.fromJson(json);
}

/// @nodoc
mixin _$CMSCourseModule {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get modname => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_CMSCourseModule implements _CMSCourseModule {
  _$_CMSCourseModule(
      {required this.id, required this.name, required this.modname});

  factory _$_CMSCourseModule.fromJson(Map<String, dynamic> json) =>
      _$$_CMSCourseModuleFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String modname;

  @override
  String toString() {
    return 'CMSCourseModule(id: $id, name: $name, modname: $modname)';
  }
}

abstract class _CMSCourseModule implements CMSCourseModule {
  factory _CMSCourseModule(
      {required final int id,
      required final String name,
      required final String modname}) = _$_CMSCourseModule;

  factory _CMSCourseModule.fromJson(Map<String, dynamic> json) =
      _$_CMSCourseModule.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get modname;
}
