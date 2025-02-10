// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_player_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VideoPlayerConfigData {
  ImpartusVideo? get previousVideo => throw _privateConstructorUsedError;
  ImpartusVideo? get nextVideo => throw _privateConstructorUsedError;
  ImpartusVideo? get currentVideo => throw _privateConstructorUsedError;
  double? get playbackSpeed => throw _privateConstructorUsedError;
  double? get playbackVolume => throw _privateConstructorUsedError;
}

/// @nodoc

class _$VideoPlayerConfigDataImpl implements _VideoPlayerConfigData {
  const _$VideoPlayerConfigDataImpl(
      {this.previousVideo,
      this.nextVideo,
      this.currentVideo,
      this.playbackSpeed,
      this.playbackVolume});

  @override
  final ImpartusVideo? previousVideo;
  @override
  final ImpartusVideo? nextVideo;
  @override
  final ImpartusVideo? currentVideo;
  @override
  final double? playbackSpeed;
  @override
  final double? playbackVolume;

  @override
  String toString() {
    return 'VideoPlayerConfigData(previousVideo: $previousVideo, nextVideo: $nextVideo, currentVideo: $currentVideo, playbackSpeed: $playbackSpeed, playbackVolume: $playbackVolume)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoPlayerConfigDataImpl &&
            (identical(other.previousVideo, previousVideo) ||
                other.previousVideo == previousVideo) &&
            (identical(other.nextVideo, nextVideo) ||
                other.nextVideo == nextVideo) &&
            (identical(other.currentVideo, currentVideo) ||
                other.currentVideo == currentVideo) &&
            (identical(other.playbackSpeed, playbackSpeed) ||
                other.playbackSpeed == playbackSpeed) &&
            (identical(other.playbackVolume, playbackVolume) ||
                other.playbackVolume == playbackVolume));
  }

  @override
  int get hashCode => Object.hash(runtimeType, previousVideo, nextVideo,
      currentVideo, playbackSpeed, playbackVolume);
}

abstract class _VideoPlayerConfigData implements VideoPlayerConfigData {
  const factory _VideoPlayerConfigData(
      {final ImpartusVideo? previousVideo,
      final ImpartusVideo? nextVideo,
      final ImpartusVideo? currentVideo,
      final double? playbackSpeed,
      final double? playbackVolume}) = _$VideoPlayerConfigDataImpl;

  @override
  ImpartusVideo? get previousVideo;
  @override
  ImpartusVideo? get nextVideo;
  @override
  ImpartusVideo? get currentVideo;
  @override
  double? get playbackSpeed;
  @override
  double? get playbackVolume;
}
