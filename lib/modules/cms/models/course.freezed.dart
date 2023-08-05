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
  int get instance => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  CMSCourseFile? get contents => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_CMSCourseModule implements _CMSCourseModule {
  _$_CMSCourseModule(
      {required this.id,
      required this.name,
      required this.modname,
      required this.instance,
      this.description,
      this.contents});

  factory _$_CMSCourseModule.fromJson(Map<String, dynamic> json) =>
      _$$_CMSCourseModuleFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String modname;
  @override
  final int instance;
  @override
  final String? description;
  @override
  final CMSCourseFile? contents;

  @override
  String toString() {
    return 'CMSCourseModule(id: $id, name: $name, modname: $modname, instance: $instance, description: $description, contents: $contents)';
  }
}

abstract class _CMSCourseModule implements CMSCourseModule {
  factory _CMSCourseModule(
      {required final int id,
      required final String name,
      required final String modname,
      required final int instance,
      final String? description,
      final CMSCourseFile? contents}) = _$_CMSCourseModule;

  factory _CMSCourseModule.fromJson(Map<String, dynamic> json) =
      _$_CMSCourseModule.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get modname;
  @override
  int get instance;
  @override
  String? get description;
  @override
  CMSCourseFile? get contents;
}

CMSCourseFile _$CMSCourseFileFromJson(Map<String, dynamic> json) {
  return _CMSCourseFile.fromJson(json);
}

/// @nodoc
mixin _$CMSCourseFile {
  String get filename => throw _privateConstructorUsedError;
  String get fileurl => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_CMSCourseFile implements _CMSCourseFile {
  const _$_CMSCourseFile({required this.filename, required this.fileurl});

  factory _$_CMSCourseFile.fromJson(Map<String, dynamic> json) =>
      _$$_CMSCourseFileFromJson(json);

  @override
  final String filename;
  @override
  final String fileurl;

  @override
  String toString() {
    return 'CMSCourseFile(filename: $filename, fileurl: $fileurl)';
  }
}

abstract class _CMSCourseFile implements CMSCourseFile {
  const factory _CMSCourseFile(
      {required final String filename,
      required final String fileurl}) = _$_CMSCourseFile;

  factory _CMSCourseFile.fromJson(Map<String, dynamic> json) =
      _$_CMSCourseFile.fromJson;

  @override
  String get filename;
  @override
  String get fileurl;
}

CMSRegisteredCourse _$CMSRegisteredCourseFromJson(Map<String, dynamic> json) {
  return _CMSRegisteredCourse.fromJson(json);
}

/// @nodoc
mixin _$CMSRegisteredCourse {
  int get id => throw _privateConstructorUsedError;
  String get displayname => throw _privateConstructorUsedError;
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$_CMSRegisteredCourse implements _CMSRegisteredCourse {
  const _$_CMSRegisteredCourse({required this.id, required this.displayname});

  factory _$_CMSRegisteredCourse.fromJson(Map<String, dynamic> json) =>
      _$$_CMSRegisteredCourseFromJson(json);

  @override
  final int id;
  @override
  final String displayname;

  @override
  String toString() {
    return 'CMSRegisteredCourse(id: $id, displayname: $displayname)';
  }
}

abstract class _CMSRegisteredCourse implements CMSRegisteredCourse {
  const factory _CMSRegisteredCourse(
      {required final int id,
      required final String displayname}) = _$_CMSRegisteredCourse;

  factory _CMSRegisteredCourse.fromJson(Map<String, dynamic> json) =
      _$_CMSRegisteredCourse.fromJson;

  @override
  int get id;
  @override
  String get displayname;
}
