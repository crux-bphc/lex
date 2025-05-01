import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/video_player_config.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/lecture_title.dart';
import 'package:lex/modules/multipartus/widgets/peekaboo.dart';
import 'package:lex/modules/multipartus/widgets/video_player/controller.dart';
import 'package:lex/modules/multipartus/widgets/video_player/utils.dart';
import 'package:lex/modules/multipartus/widgets/video_player/widgets.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/error.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/theme.dart';
import 'package:lex/utils/extensions.dart';
import 'package:lex/utils/shortcut.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';

const _baseUrl = String.fromEnvironment("LEX_BACKEND_URL");

String _getVideoUrl(String ttid) {
  return '$_baseUrl/impartus/ttid/$ttid/m3u8';
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
  late final MultiViewVideoController controller;

  StreamSubscription<Duration>? _positionStream;
  StreamSubscription<double>? _volumeStream, _rateStream;
  StreamSubscription<Tracks>? _tracksStream;

  Stopwatch? _positionUpdateStopwatch;

  EffectCleanup? _cleanup;

  @override
  void initState() {
    super.initState();

    player = Player();

    controller = MultiViewVideoController(
      player: player,
      videoWidgetKey: _videoKey,
    );

    _setup();
  }

  @override
  void dispose() {
    debugPrint("dispose");
    _positionUpdateStopwatch?.stop();

    _tracksStream?.cancel();
    _positionStream?.cancel();
    _rateStream?.cancel();
    _volumeStream?.cancel();

    _cleanup?.call();

    controller.dispose();

    player.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ttid != widget.ttid) _setup();
  }

  void _setup() async {
    final isDown =
        await GetIt.instance<MultipartusService>().isImpartusDown(widget.ttid);
    if (isDown) {
      GetIt.instance<ErrorService>().reportError(
        "Impartus servers may be down. Please try again later.",
      );
      return;
    }

    final idToken = GetIt.instance<AuthProvider>().currentUser.value!.idToken!;

    await player.open(
      Media(
        _getVideoUrl(widget.ttid),
        httpHeaders: {
          'Authorization': 'Bearer $idToken',
        },
      ),
    );

    _tracksStream?.cancel();
    _tracksStream = player.stream.tracks.listen((s) async {
      debugPrint("set");
      final bestTrack = s.video
          .map((e) => (e, e.h ?? 0))
          .reduce((a, b) => a.$2 > b.$2 ? a : b)
          .$1;
      await player.setVideoTrack(bestTrack);
    });

    // double video view check
    if (!mounted) return;
    final views = SignalProvider.of<VideoPlayerConfig>(context, listen: false)
        ?.select((v) => v().availableViews);
    assert(views != null, "No VideoPlayerConfig signal found in tree");

    _cleanup = effect(() {
      controller.hasTwoViews = views!() == 2;
    });

    _applyConfig();

    // play right after we get the value of duration
    player.stream.duration.first.then((_) async {
      await player.seek(widget.startTimestamp);
    }).catchError((_) {});
    // ^ ignore bad state errors

    // play after buffering is done
    player.stream.buffering.firstWhere((e) => e == false).then((_) {
      player.play();
    }).catchError((_) {});
    // ^ ignore bad state errors

    _positionStream?.cancel();
    _rateStream?.cancel();
    _volumeStream?.cancel();

    // store volume and rate in preferences
    _volumeStream = player.stream.volume.listen((v) {
      GetIt.instance<LocalStorage>().preferences.playbackVolume.value = v;
    });

    _rateStream = player.stream.rate.listen((r) {
      GetIt.instance<LocalStorage>().preferences.playbackSpeed.value = r;
    });
    // dont bother setting up listeners if there is no callback
    if (widget.onPositionChanged == null) return;

    _positionUpdateStopwatch = Stopwatch()..start();

    _positionStream = player.stream.position.listen((position) {
      // call onPositionChanged every `positionUpdateInterval`
      final shouldUpdate = mounted &&
          player.state.playing &&
          _positionUpdateStopwatch!.elapsed > widget.positionUpdateInterval;

      if (shouldUpdate) {
        final fraction =
            controller.getViewAwareFraction(position).clampNaN(0, 1);

        widget.onPositionChanged!.call(position, fraction);

        _positionUpdateStopwatch!.reset();
      }
    });
  }

  /// Apply video config to the player, called by _setup whenever the video
  /// player changes
  void _applyConfig() {
    player.setRate(
      GetIt.instance<LocalStorage>().preferences.playbackSpeed.value,
    );
    player.setVolume(
      GetIt.instance<LocalStorage>().preferences.playbackVolume.value,
    );
  }

  /// Start the continuous seek operation.
  ///
  /// Continuous seek happens when the user holds down any of the seek buttons
  /// or repeatedly presses them for quickly seeking to a position. This method
  /// is called on KeyDown and KeyRepeat events.
  void _startContinuousSeek(Duration seekDuration) {
    final effectiveSeek = seekDuration * player.state.rate;
    controller.startViewAwareContinuousSeek(effectiveSeek);
  }

  void _continuousSeekBy(Duration seekDuration) {
    final effectiveSeek = seekDuration * player.state.rate;
    controller.viewAwareContinuousSeekBy(effectiveSeek);
  }

  /// Stop the continuous seek operation after the video
  /// player finishes loading.
  ///
  /// This method is called on KeyUp events.
  void _stopContinuousSeek() async {
    await player.stream.buffering.firstWhere((e) => e == false);
    controller.stopContinuousSeek();
  }

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
      keyboardShortcuts: {
        // left arrow - backward
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.arrowLeft):
            () => _startContinuousSeek(Duration(seconds: -5)),
        KeyEventShortcutActivator<KeyRepeatEvent>(LogicalKeyboardKey.arrowLeft):
            () => _continuousSeekBy(Duration(seconds: -5)),
        KeyEventShortcutActivator<KeyUpEvent>(LogicalKeyboardKey.arrowLeft):
            () => _stopContinuousSeek(),

        // right arrow - forward
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.arrowRight):
            () => _startContinuousSeek(Duration(seconds: 5)),
        KeyEventShortcutActivator<KeyRepeatEvent>(
          LogicalKeyboardKey.arrowRight,
        ): () => _continuousSeekBy(Duration(seconds: 5)),
        KeyEventShortcutActivator<KeyUpEvent>(LogicalKeyboardKey.arrowRight):
            _stopContinuousSeek,

        // J key - backward
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.keyJ): () =>
            _startContinuousSeek(Duration(seconds: -10)),
        KeyEventShortcutActivator<KeyRepeatEvent>(LogicalKeyboardKey.keyJ):
            () => _continuousSeekBy(Duration(seconds: -10)),
        KeyEventShortcutActivator<KeyUpEvent>(LogicalKeyboardKey.keyJ):
            _stopContinuousSeek,

        // L key - forward
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.keyL): () =>
            _startContinuousSeek(Duration(seconds: 10)),
        KeyEventShortcutActivator<KeyRepeatEvent>(LogicalKeyboardKey.keyL):
            () => _continuousSeekBy(Duration(seconds: 10)),
        KeyEventShortcutActivator<KeyUpEvent>(LogicalKeyboardKey.keyL):
            _stopContinuousSeek,

        // space key - play or pause
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.space):
            player.playOrPause,

        // S key - switch views
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.keyS):
            controller.switchViews,

        // M key - mute
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.keyM):
            controller.toggleMute,

        // Fullscreen
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.keyF):
            controller.toggleFullscreen,
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.escape):
            controller.exitFullscreen,

        // Shift + P - previous video
        KeyEventShortcutActivator<KeyDownEvent>(
          LogicalKeyboardKey.keyP,
          shift: true,
        ): () => controller.navigateVideo(context, NavigationType.previous),

        // Shift + N - next video
        KeyEventShortcutActivator<KeyDownEvent>(
          LogicalKeyboardKey.keyN,
          shift: true,
        ): () => controller.navigateVideo(context, NavigationType.next),

        // Shift + . - increase speed
        KeyEventShortcutActivator<KeyDownEvent>(
          LogicalKeyboardKey.greater,
        ): controller.increaseRate,
        KeyEventShortcutActivator<KeyDownEvent>(
          LogicalKeyboardKey.period,
          shift: true,
        ): controller.increaseRate,

        // Shift + , - decrease speed
        KeyEventShortcutActivator<KeyDownEvent>(
          LogicalKeyboardKey.less,
        ): controller.decreaseRate,
        KeyEventShortcutActivator<KeyDownEvent>(
          LogicalKeyboardKey.comma,
          shift: true,
        ): controller.decreaseRate,

        // Down arrow - decrease volume
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.arrowDown):
            controller.decreaseVolume,

        // Up arrow - increase volume
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.arrowUp):
            controller.increaseVolume,
      },
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
                ImpartusSeekBar(),
                // we listen to the config here
                Watch(
                  (_) => _VideoControlsRow(
                    config: config!(),
                    onNavigate: (navType) =>
                        controller.navigateVideo(context, navType),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
              child: Theme(
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
                          Duration(milliseconds: 200),
                          player.play,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Video controls

class _VideoControlsRow extends StatelessWidget {
  const _VideoControlsRow({required this.config, required this.onNavigate});

  final VideoPlayerConfigData config;
  final void Function(NavigationType navType) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // show if there is a previous video
        PeekaBoo(
          alignment: Alignment.centerLeft,
          child: (config.previousVideo != null)
              ? VideoNavigationButton(
                  lectureNo: config.previousVideo!.lectureNo.toString(),
                  title: config.previousVideo!.title,
                  icon: Icon(LucideIcons.skip_back),
                  onPressed: () => onNavigate(NavigationType.previous),
                )
              : null,
        ),

        PlayPauseButton(),

        // show if there is a next video
        PeekaBoo(
          alignment: Alignment.centerRight,
          child: config.nextVideo != null
              ? VideoNavigationButton(
                  lectureNo: config.nextVideo!.lectureNo.toString(),
                  title: config.nextVideo!.title,
                  icon: Icon(LucideIcons.skip_forward),
                  onPressed: () => onNavigate(NavigationType.next),
                )
              : null,
        ),

        VolumeButton(),

        PositionIndicator(),

        Spacer(),

        SpeedButton(),

        PeekaBoo(
          alignment: Alignment.centerLeft,
          child: config.availableViews > 1 ? SwitchViewButton() : null,
        ),

        if (kIsWeb) ShareButton(),

        FullscreenButton(),
      ],
    );
  }
}
