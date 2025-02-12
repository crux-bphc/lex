import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/video_player_config.dart';
import 'package:lex/modules/multipartus/widgets/lecture_title.dart';
import 'package:lex/modules/multipartus/widgets/seekbar.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/theme.dart';
import 'package:lex/utils/extensions.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';

const _controlsIconSize = 24.0;

String _getVideoUrl(String baseUrl, String ttid) {
  return '$baseUrl/impartus/ttid/$ttid/m3u8';
}

final _videoKey = GlobalKey<VideoState>();

/// Custom made video player with custom controls.
class VideoPlayer extends StatefulWidget {
  const VideoPlayer({
    super.key,
    required this.ttid,
    required this.startTimestamp,
    this.onPositionChanged,
    this.positionUpdateInterval = const Duration(seconds: 3),
  });

  final String ttid;
  final Duration startTimestamp;
  final void Function(Duration position, double fractionComplete)?
      onPositionChanged;
  final Duration positionUpdateInterval;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final Player player;
  late final VideoController controller;

  StreamSubscription<Duration>? _positionStream;
  StreamSubscription<double>? _volumeStream, _rateStream;
  final _positionUpdateStopwatch = Stopwatch()..start();

  @override
  void initState() {
    super.initState();

    player = Player();

    controller = VideoController(player);

    _setup();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _volumeStream?.cancel();
    _rateStream?.cancel();
    _positionUpdateStopwatch.stop();

    player.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ttid != widget.ttid) _setup();
  }

  void _applyConfig() {
    player.seek(widget.startTimestamp);
    player.setRate(
      GetIt.instance<LocalStorage>().preferences.playbackSpeed.value,
    );
    player.setVolume(
      GetIt.instance<LocalStorage>().preferences.playbackVolume.value,
    );
  }

  void _setup() async {
    final client = GetIt.instance<AuthProvider>().dioClient;
    final idToken = Uri.encodeQueryComponent(
      GetIt.instance<AuthProvider>().currentUser.value!.idToken!,
    );
    final baseUrl = client.options.baseUrl;

    await player.open(
      Media(
        _getVideoUrl(baseUrl, widget.ttid),
        httpHeaders: {
          'Authorization': 'Bearer $idToken',
        },
      ),
    );

    _applyConfig();

    player.stream.buffering
        .firstWhere((e) => e == false)
        .then((_) => player.play());

    if (widget.onPositionChanged == null) return;

    _positionStream = player.stream.position.listen((position) {
      final shouldUpdate = mounted &&
          player.state.playing &&
          _positionUpdateStopwatch.elapsed > widget.positionUpdateInterval;

      if (shouldUpdate) {
        final fraction = actualFraction(position, player.state.duration);

        widget.onPositionChanged!.call(position, fraction);

        _positionUpdateStopwatch.reset();
      }
    });

    _volumeStream = player.stream.volume.listen((v) {
      GetIt.instance<LocalStorage>().preferences.playbackVolume.value = v;
    });

    _rateStream = player.stream.rate.listen((r) {
      GetIt.instance<LocalStorage>().preferences.playbackSpeed.value = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: AspectRatio(
              aspectRatio: 1280 / 720,
              child: Stack(
                children: [
                  // Hero(
                  //   tag: widget.ttid,
                  //   createRectTween: (begin, end) =>
                  //       CurvedRectTween(begin: begin!, end: end!),
                  //   child: VideoThumbnail(
                  //     ttid: widget.ttid,
                  //     fit: BoxFit.cover,
                  //     width: double.infinity,
                  //   ),
                  // ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: Theme.of(context)
                          .textTheme
                          .apply(bodyColor: Colors.white),
                    ),
                    child: MaterialDesktopVideoControlsTheme(
                      normal: buildDesktopControls(
                        context,
                        isFullscreen: false,
                      ),
                      fullscreen: buildDesktopControls(
                        context,
                        isFullscreen: true,
                      ),
                      child: Video(
                        key: _videoKey,
                        controller: controller,
                        onEnterFullscreen: () async {
                          final shouldPlay = player.state.playing;

                          // great library, I have to call this myself
                          await defaultEnterNativeFullscreen();

                          if (shouldPlay) player.play();
                        },
                        onExitFullscreen: () async {
                          final shouldPlay = player.state.playing;

                          await defaultExitNativeFullscreen();

                          if (shouldPlay) {
                            Future.delayed(
                              Duration(milliseconds: 500),
                              player.play,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Video controls

VideoController getController(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.controller;

MaterialDesktopVideoControlsThemeData buildDesktopControls(
  BuildContext context, {
  required bool isFullscreen,
}) {
  // if we listen here the widgets that we need to update (nav buttons) will not
  // update because theme data doesnt just rebuild like that
  final config = SignalProvider.of<VideoPlayerConfig>(context, listen: false);
  assert(config != null, "No VideoPlayerConfig signal found in tree");

  return MaterialDesktopVideoControlsThemeData(
    seekBarPositionColor: Theme.of(context).colorScheme.primary,
    seekBarThumbColor: Theme.of(context).colorScheme.primary,
    controlsHoverDuration: 5.seconds,
    hideMouseOnControlsRemoval: true,
    displaySeekBar: false,
    buttonBarHeight: 80,
    seekBarMargin: EdgeInsets.zero,
    seekBarContainerHeight: 8,
    topButtonBar: [
      if (isFullscreen)
        Expanded(
          child: Watch((context) {
            final vid = config!().currentVideo;

            if (vid == null) return SizedBox();

            return LectureTitle(
              lectureNo: vid.lectureNo.toString(),
              title: vid.title,
              titleColor: Theme.of(context).colorScheme.onSurface,
              lectureNoColor: Colors.black,
              showShadows: true,
              maxLines: 1,
            );
          }),
        ),
    ],
    bottomButtonBar: [
      Expanded(
        child: Theme(
          data: buildTheme(ThemeMode.dark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ImpartusSeekBar(),
              // we listen to the conig here
              Watch(
                (_) => _VideoControlsRow(
                  config: config!(),
                  onNavigate: (navType) =>
                      VideoNavigateNotification(navType).dispatch(context),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _VideoControlsRow extends StatelessWidget {
  const _VideoControlsRow({required this.config, required this.onNavigate});

  final VideoPlayerConfigData config;
  final void Function(NavigationType navType) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (config.previousVideo != null)
          _VideoNavigationButton(
            lectureNo: config.previousVideo!.lectureNo.toString(),
            title: config.previousVideo!.title,
            icon: Icon(LucideIcons.skip_back),
            onPressed: () => onNavigate(NavigationType.previous),
          ),
        _PlayPauseButton(),
        if (config.nextVideo != null)
          _VideoNavigationButton(
            lectureNo: config.nextVideo!.lectureNo.toString(),
            title: config.nextVideo!.title,
            icon: Icon(LucideIcons.skip_forward),
            onPressed: () => onNavigate(NavigationType.next),
          ),
        _VolumeButton(),
        _ImpartusPositionIndicator(),
        Spacer(),
        _SpeedButton(),
        _SwitchViewButton(),
        if (kIsWeb) _ShareButton(),
        // _PitchButton(),
        _FullscreenButton(),
      ],
    );
  }
}

class _VideoNavigationButton extends StatelessWidget {
  const _VideoNavigationButton({
    required this.lectureNo,
    required this.title,
    required this.onPressed,
    required this.icon,
  });

  final String lectureNo, title;
  final void Function() onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: buildLectureTitleSpan(
        lectureNo: lectureNo,
        title: title,
        fontSize: 14,
        titleColor: Theme.of(context).colorScheme.surface,
        lectureNoColor: Theme.of(context).colorScheme.onSurface,
        borderRadius: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.onSurface,
      ),
      waitDuration: Duration.zero,
      padding: EdgeInsets.fromLTRB(4, 4, 6, 4),
      child: MaterialDesktopCustomButton(
        onPressed: () async {
          late final isFullscreen =
              (_videoKey.currentState?.isFullscreen() ?? false);

          if (kIsWeb && isFullscreen) {
            await defaultExitNativeFullscreen();
            await _videoKey.currentState?.exitFullscreen();
          }
          onPressed();
        },
        iconSize: _controlsIconSize,
        icon: icon,
      ),
    );
  }
}

// class _PitchButton extends StatelessWidget {
//   const _PitchButton();

//   @override
//   Widget build(BuildContext context) {
//     final controller = getController(context);
//     return MaterialDesktopCustomButton(
//       onPressed: () {
//         controller.player
//             .setPitch(controller.player.state.pitch == 1.0 ? 1.6 : 1.0);
//       },
//       icon: Icon(LucideIcons.audio_waveform),
//     );
//   }
// }

class _VolumeButton extends StatefulWidget {
  const _VolumeButton();

  @override
  State<_VolumeButton> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<_VolumeButton> {
  late final controller = getController(context);
  late final _volumeSignal = controller.player.stream.volume
      .toSyncSignal(controller.player.state.volume);

  late double _oldVolume = controller.player.state.volume;

  @override
  Widget build(BuildContext context) {
    final volume = _volumeSignal.watch(context);

    return _PeekaBooSlider(
      value: volume,
      min: 0,
      max: 100,
      sliderWidth: 80,
      onChanged: (volume) => controller.player.setVolume(volume),
      isButtonLeading: true,
      button: MaterialDesktopCustomButton(
        iconSize: _controlsIconSize,
        icon: switch (volume) {
          0 => Icon(LucideIcons.volume_off),
          < 50 => Icon(LucideIcons.volume_1),
          _ => Icon(LucideIcons.volume_2)
        },
        onPressed: () {
          if (volume == 0) {
            // unmuting
            controller.player.setVolume(_oldVolume != 0 ? _oldVolume : 100);
          } else {
            // muting
            _oldVolume = volume;
            controller.player.setVolume(0);
          }
        },
      ),
    );
  }
}

class _FullscreenButton extends StatelessWidget {
  const _FullscreenButton();

  @override
  Widget build(BuildContext context) {
    return MaterialFullscreenButton(
      icon: Tooltip(
        message: isFullscreen(context) ? 'Exit full screen' : 'Full screen',
        child: Icon(
          isFullscreen(context) ? LucideIcons.minimize : LucideIcons.maximize,
        ),
      ),
    );
  }
}

class _SpeedButton extends StatefulWidget {
  const _SpeedButton();

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton>
    with SingleTickerProviderStateMixin {
  late final _buttonController = AnimationController(
    vsync: this,
    duration: Durations.short4,
  );

  late final controller = getController(context);
  late final _playbackRate =
      controller.player.stream.rate.toSyncSignal(controller.player.state.rate);

  double _bounceDirection = 1;

  void _handleIncreaseSpeed() {
    controller.player.setRate(
      _playbackRate() > 2.75 ? 0.25 : _playbackRate() + 0.25,
    );
    _bounceDirection = 1;
    _buttonController.forward(from: 0);
  }

  void _handleDecreaseSpeed() {
    controller.player.setRate(
      _playbackRate() < 0.5 ? 3.0 : _playbackRate() - 0.25,
    );
    _bounceDirection = -1;
    _buttonController.forward(from: 0);
  }

  void _setRate(double rate) {
    controller.player.setRate(rate);
  }

  @override
  Widget build(BuildContext context) {
    final playbackRate = _playbackRate.watch(context);

    return _PeekaBooSlider(
      min: 0.25,
      max: 3.0,
      divisions: 11,
      onChanged: _setRate,
      value: playbackRate,
      valueFormatter: (value) => "${value}x",
      showLabel: true,
      isButtonLeading: false,
      button: GestureDetector(
        onSecondaryTap: _handleDecreaseSpeed,
        child: MaterialDesktopCustomButton(
          onPressed: _handleIncreaseSpeed,
          iconSize: _controlsIconSize + 4,
          icon: Tooltip(
            message: "Playback speed",
            child: Icon(LucideIcons.chevrons_right),
          ).animate(controller: _buttonController, autoPlay: false).custom(
                builder: (context, value, child) => Transform(
                  transform: Matrix4.translationValues(
                    _bounceDirection * 12 * value * (1 - value),
                    0,
                    0,
                  ),
                  child: child,
                ),
                duration: 140.ms,
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();

    super.dispose();
  }
}

class _SwitchViewButton extends StatelessWidget {
  const _SwitchViewButton();

  @override
  Widget build(BuildContext context) {
    final controller = getController(context);
    return MaterialCustomButton(
      onPressed: () {
        final total = controller.player.state.duration.inMilliseconds;
        final totalHalf = total ~/ 2;
        final current = controller.player.state.position.inMilliseconds;
        final newPos =
            (current > totalHalf ? current - totalHalf : current + totalHalf)
                .clamp(0, total);

        controller.player.seek(Duration(milliseconds: newPos));
      },
      icon: Tooltip(
        message: 'Switch view',
        child: Icon(LucideIcons.columns_2),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = getController(context);
    return MaterialCustomButton(
      icon: StreamBuilder(
        stream: controller.player.stream.playing,
        initialData: controller.player.state.playing,
        builder: (context, snapshot) {
          return Icon(
            snapshot.data! ? LucideIcons.pause : LucideIcons.play,
          );
        },
      ),
      onPressed: controller.player.playOrPause,
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton();

  @override
  Widget build(BuildContext context) {
    final controller = getController(context);

    return MaterialCustomButton(
      onPressed: () async {
        final currentPosition = controller.player.state.position;
        final videoUrl = Uri.base.replace(
          queryParameters: {
            ...Uri.base.queryParameters,
            't': currentPosition.inSeconds.toString(),
          },
        ).toString();

        Clipboard.setData(ClipboardData(text: videoUrl));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link copied to clipboard!')),
        );
      },
      icon: Tooltip(
        message: 'Share',
        child: Icon(Icons.share),
      ),
    );
  }
}

Duration actualDuration(Duration totalDuration) =>
    totalDuration == Duration.zero
        ? const Duration(minutes: 59, seconds: 59)
        : totalDuration * 0.5;

bool isView2(Duration position, Duration totalDuration) =>
    position > actualDuration(totalDuration);

Duration actualPosition(Duration position, Duration totalDuration) =>
    isView2(position, totalDuration)
        ? position - actualDuration(totalDuration)
        : position;

double actualFraction(Duration position, Duration totalDuration) =>
    actualPosition(position, totalDuration).inMilliseconds /
    actualDuration(totalDuration).inMilliseconds;

class _ImpartusSeekBar extends StatefulWidget {
  const _ImpartusSeekBar();

  @override
  State<_ImpartusSeekBar> createState() => _ImpartusSeekBarState();
}

class _ImpartusSeekBarState extends State<_ImpartusSeekBar> {
  late final controller = getController(context);

  Duration get totalDuration => controller.player.state.duration;

  MaterialDesktopVideoControlsThemeData? _theme(BuildContext context) =>
      isFullscreen(context)
          ? MaterialDesktopVideoControlsTheme.maybeOf(context)?.fullscreen
          : MaterialDesktopVideoControlsTheme.maybeOf(context)?.normal;

  @override
  Widget build(BuildContext context) {
    return SeekBar(
      barColor: _theme(context)?.seekBarColor,
      thumbColor: _theme(context)?.seekBarThumbColor,
      positionColor: _theme(context)?.seekBarPositionColor,
      bufferFraction: controller.player.stream.buffer.map(
        (e) => actualFraction(e, totalDuration).clampNaN(0, 1),
      ),
      positionFraction: controller.player.stream.position.map(
        (e) => actualFraction(e, totalDuration).clampNaN(0, 1),
      ),
      initialBuffer:
          actualFraction(controller.player.state.buffer, totalDuration)
              .clampNaN(0, 1),
      initialPosition:
          actualFraction(controller.player.state.position, totalDuration)
              .clampNaN(0, 1),
      formatTimestamp: (positionFraction) {
        final pos = actualDuration(totalDuration) * positionFraction;
        return pos.format();
      },
      onSeek: (p) {
        final actual = actualDuration(totalDuration);
        controller.player.seek(
          isView2(controller.player.state.position, totalDuration)
              ? actual + actual * p
              : actual * p,
        );
      },
    );
  }
}

class _ImpartusPositionIndicator extends StatefulWidget {
  const _ImpartusPositionIndicator();

  @override
  State<_ImpartusPositionIndicator> createState() =>
      _ImpartusPositionIndicatorState();
}

class _ImpartusPositionIndicatorState extends State<_ImpartusPositionIndicator>
    with SignalsMixin {
  late final controller = getController(context);

  late final position = createStreamSignal(
    () => controller.player.stream.position
        .map((e) => actualPosition(e, totalDuration)),
    initialValue:
        actualPosition(controller.player.state.position, totalDuration),
  );

  late final duration = createStreamSignal(
    () => controller.player.stream.duration.map(actualDuration),
    initialValue: actualDuration(totalDuration),
  );

  Duration get totalDuration => controller.player.state.duration;

  @override
  Widget build(BuildContext context) {
    return Text(
      "${position().value!.format()} / ${duration().value!.format()}",
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        height: 1,
      ),
    );
  }
}

class VideoNavigateNotification extends Notification {
  final NavigationType navigationType;

  VideoNavigateNotification(this.navigationType);
}

enum NavigationType {
  next,
  previous;

  int get offset => switch (this) {
        NavigationType.next => 1,
        NavigationType.previous => -1,
      };
}

class _PeekaBooSlider extends StatefulWidget {
  const _PeekaBooSlider({
    required this.button,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.valueFormatter,
    this.sliderWidth = 120,
    this.divisions,
    this.showLabel = false,
    this.isButtonLeading = true,
  }) : assert(
          valueFormatter == null || showLabel,
          "valueFormatter must not be null if showLabel is true",
        );

  final double value, min, max, sliderWidth;
  final double spacing = 8;
  final int? divisions;
  final Widget button;
  final String Function(double value)? valueFormatter;
  final void Function(double value) onChanged;
  final bool showLabel, isButtonLeading;

  @override
  State<_PeekaBooSlider> createState() => _PeekaBooSliderState();
}

class _PeekaBooSliderState extends State<_PeekaBooSlider> {
  final _isHovering = signal(false);

  @override
  Widget build(BuildContext context) {
    final first =
        widget.isButtonLeading ? (widget.button) : _buildText(context);
    final space = SizedBox(width: widget.spacing);
    final last = widget.isButtonLeading ? _buildText(context) : (widget.button);

    return MouseRegion(
      onEnter: (_) => _isHovering.value = true,
      onExit: (_) => _isHovering.value = false,
      child: Row(
        children: [
          first,
          if (!widget.isButtonLeading) space,
          _buildMiddle(context),
          if (widget.isButtonLeading) space,
          last,
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context) => widget.showLabel
      ? Text(
          widget.valueFormatter!(widget.value),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1,
          ),
        )
      : SizedBox();

  Widget _buildMiddle(BuildContext context) => Watch(
        (context) => AnimatedSize(
          duration: Durations.short3,
          alignment: widget.isButtonLeading
              ? Alignment.centerRight
              : Alignment.centerLeft,
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: Durations.short4,
            child: _isHovering()
                ? _Slider(
                    value: widget.value,
                    min: widget.min,
                    max: widget.max,
                    spacing: widget.spacing,
                    sliderWidth: widget.sliderWidth,
                    onChanged: widget.onChanged,
                    isButtonLeading: widget.isButtonLeading,
                    divisions: widget.divisions,
                  )
                : SizedBox(),
          ),
        ),
      );
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.value,
    required this.min,
    required this.max,
    required this.spacing,
    required this.sliderWidth,
    this.divisions,
    required this.onChanged,
    required this.isButtonLeading,
  });

  final double value, min, max, spacing, sliderWidth;
  final int? divisions;

  final void Function(double value) onChanged;
  final bool isButtonLeading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: sliderWidth,
      margin: EdgeInsets.only(
        left: isButtonLeading ? spacing : 0,
        right: isButtonLeading ? 0 : spacing,
      ),
      child: SliderTheme(
        data: SliderThemeData(
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6,
            disabledThumbRadius: 6,
          ),
          trackHeight: 1,
          overlayShape: SliderComponentShape.noOverlay,
          thumbColor: Theme.of(context).colorScheme.onSurface,
          activeTrackColor: Theme.of(context).colorScheme.onSurface,
          inactiveTrackColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
