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
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:signals/signals_flutter.dart';

const _controlsIconSize = 24.0;
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

  final _positionUpdateStopwatch = Stopwatch()..start();

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

  void _setup() async {
    final idToken = Uri.encodeQueryComponent(
      GetIt.instance<AuthProvider>().currentUser.value!.idToken!,
    );

    await player.open(
      Media(
        _getVideoUrl(widget.ttid),
        httpHeaders: {
          'Authorization': 'Bearer $idToken',
        },
      ),
    );

    _applyConfig();

    // play right after we get the value of duration
    player.stream.duration.first.then((_) async {
      await player.seek(widget.startTimestamp);
    });

    player.stream.buffering.firstWhere((e) => e == false).then((_) {
      player.play();
    });

    // dont bother setting up listeners if there is no callback
    if (widget.onPositionChanged == null) return;

    _positionStream = player.stream.position.listen((position) {
      // call onPositionChanged every `positionUpdateInterval`
      final shouldUpdate = mounted &&
          player.state.playing &&
          _positionUpdateStopwatch.elapsed > widget.positionUpdateInterval;

      if (shouldUpdate) {
        final fraction = controller.getViewAwareFraction(position);

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
            () => _startContinuousSeek(Duration(seconds: -10)),
        KeyEventShortcutActivator<KeyRepeatEvent>(LogicalKeyboardKey.arrowLeft):
            () => _startContinuousSeek(Duration(seconds: -10)),
        KeyEventShortcutActivator<KeyUpEvent>(LogicalKeyboardKey.arrowLeft):
            () => _stopContinuousSeek(),

        // right arrow - forward
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.arrowRight):
            () => _startContinuousSeek(Duration(seconds: 10)),
        KeyEventShortcutActivator<KeyRepeatEvent>(
          LogicalKeyboardKey.arrowRight,
        ): () => _startContinuousSeek(Duration(seconds: 10)),
        KeyEventShortcutActivator<KeyUpEvent>(LogicalKeyboardKey.arrowRight):
            _stopContinuousSeek,

        // J key - backward
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.keyJ): () =>
            _startContinuousSeek(Duration(seconds: -10)),
        KeyEventShortcutActivator<KeyRepeatEvent>(LogicalKeyboardKey.keyJ):
            () => _startContinuousSeek(Duration(seconds: -10)),
        KeyEventShortcutActivator<KeyUpEvent>(LogicalKeyboardKey.keyJ):
            _stopContinuousSeek,

        // L key - forward
        KeyEventShortcutActivator<KeyDownEvent>(LogicalKeyboardKey.keyL): () =>
            _startContinuousSeek(Duration(seconds: 10)),
        KeyEventShortcutActivator<KeyRepeatEvent>(LogicalKeyboardKey.keyL):
            () => _startContinuousSeek(Duration(seconds: 10)),
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

        // Shift + , - decrease speed
        KeyEventShortcutActivator<KeyDownEvent>(
          LogicalKeyboardKey.less,
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
                _ImpartusSeekBar(),
                // we listen to the config here
                Watch(
                  (_) => _VideoControlsRow(
                      config: config!(),
                      onNavigate: (navType) =>
                          controller.navigateVideo(context, navType)),
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

MultiViewVideoController getController(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.controller
        as MultiViewVideoController;

class _VideoControlsRow extends StatelessWidget {
  const _VideoControlsRow({required this.config, required this.onNavigate});

  final VideoPlayerConfigData config;
  final void Function(NavigationType navType) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // show if there is a previous video
        if (config.previousVideo != null)
          _VideoNavigationButton(
            lectureNo: config.previousVideo!.lectureNo.toString(),
            title: config.previousVideo!.title,
            icon: Icon(LucideIcons.skip_back),
            onPressed: () => onNavigate(NavigationType.previous),
          ),

        _PlayPauseButton(),

        // show if there is a next video
        if (config.nextVideo != null)
          _VideoNavigationButton(
            lectureNo: config.nextVideo!.lectureNo.toString(),
            title: config.nextVideo!.title,
            icon: Icon(LucideIcons.skip_forward),
            onPressed: () => onNavigate(NavigationType.next),
          ),

        _VolumeButton(),

        _PositionIndicator(),

        Spacer(),

        _SpeedButton(),

        _SwitchViewButton(),

        if (kIsWeb) _ShareButton(),

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
      richMessage: LectureTitle.buildSpan(
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
        onPressed: onPressed,
        iconSize: _controlsIconSize,
        icon: icon,
      ),
    );
  }
}

class _VolumeButton extends StatefulWidget {
  const _VolumeButton();

  @override
  State<_VolumeButton> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<_VolumeButton> {
  late final controller = getController(context);
  late final _volumeSignal = controller.player.stream.volume
      .toSyncSignal(controller.player.state.volume);

  @override
  Widget build(BuildContext context) {
    final volume = _volumeSignal.watch(context);

    return _PeekaBooSlider(
      value: volume,
      min: 0,
      max: 100,
      sliderWidth: 80,
      onChanged: controller.player.setVolume,
      isButtonLeading: true,
      button: MaterialDesktopCustomButton(
        iconSize: _controlsIconSize,
        icon: switch (volume) {
          0 => Tooltip(
              message: "Unmute (M)",
              child: Icon(LucideIcons.volume_off),
            ),
          < 50 => Tooltip(
              message: "Mute (M)",
              child: Icon(LucideIcons.volume_1),
            ),
          _ => Tooltip(
              message: "Mute (M)",
              child: Icon(LucideIcons.volume_2),
            )
        },
        onPressed: controller.toggleMute,
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
        message:
            isFullscreen(context) ? 'Exit full screen (F)' : 'Full screen (F)',
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
    controller.increaseRate();

    _bounceDirection = 1;
    _buttonController.forward(from: 0);
  }

  void _handleDecreaseSpeed() {
    controller.decreaseRate();

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
        controller.switchViews();
      },
      icon: Tooltip(
        message: 'Switch view (S)',
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

Duration getViewAwareDuration(Duration totalDuration) =>
    totalDuration == Duration.zero
        ? const Duration(minutes: 59, seconds: 59)
        : totalDuration * 0.5;

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
      bufferFraction: controller.viewAwareBufferFractionStream,
      positionFraction: controller.viewAwarePositionFractionStream,
      initialBuffer: controller
          .getViewAwareFraction(controller.player.state.buffer)
          .clampNaN(0, 1),
      initialPosition: controller
          .getViewAwareFraction(controller.player.state.position)
          .clampNaN(0, 1),
      formatTimestamp: (positionFraction) {
        final pos = getViewAwareDuration(totalDuration) * positionFraction;
        return pos.format();
      },
      onSeek: (p) {
        controller.viewAwareFractionalSeek(p);
      },
    );
  }
}

class _PositionIndicator extends StatefulWidget {
  const _PositionIndicator();

  @override
  State<_PositionIndicator> createState() => _PositionIndicatorState();
}

class _PositionIndicatorState extends State<_PositionIndicator>
    with SignalsMixin {
  late final controller = getController(context);

  late final position = createStreamSignal(
    () => controller.viewAwarePositionStream,
    initialValue:
        controller.getViewAwarePosition(controller.player.state.position),
  );

  late final duration = createStreamSignal(
    () => controller.viewAwareDurationStream,
    initialValue: getViewAwareDuration(totalDuration),
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

/// A widget that with a button and a slider.
/// The slider is hidden unless hovered upon.
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
  late final _isHovering = signal(false);

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
          curve: Curves.easeInOutQuad,
          child: AnimatedSwitcher(
            duration: Durations.short3,
            child: _isHovering()
                ? _Slider(
                    key: ValueKey(widget.max),
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
    super.key,
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

class KeyEventShortcutActivator<T> extends ShortcutActivator {
  final LogicalKeyboardKey trigger;
  final bool shift;

  KeyEventShortcutActivator(
    this.trigger, {
    this.shift = false,
  });

  @override
  bool accepts(KeyEvent event, HardwareKeyboard state) {
    if (event is! T) return false;

    if (event.logicalKey == trigger) {
      return state.isShiftPressed || !shift;
    }
    return event.logicalKey == trigger;
  }

  @override
  String debugDescribeKeys() {
    final result = [
      if (shift) 'Shift',
      trigger.debugName ?? trigger.toStringShort(),
    ];
    return result.join(' + ');
  }
}

class MultiViewVideoController extends VideoController {
  final GlobalKey<VideoState> videoWidgetKey;

  MultiViewVideoController({
    required Player player,
    required this.videoWidgetKey,
  }) : super(player) {
    player.stream.position.listen((event) {
      if (_continuousSeekPosition == null) {
        _positionStreamController.add(getViewAwarePosition(event));
      }
    });
  }

  late double _beforeMutingVolume = player.state.volume;

  Duration? _continuousSeekPosition;

  Duration get totalDuration => player.state.duration;

  late final viewAwareBufferFractionStream = player.stream.buffer.map(
    (e) => getViewAwareFraction(e).clampNaN(0, 1),
  );

  late final viewAwareDurationStream =
      player.stream.duration.map(getViewAwareDuration);

  final _positionStreamController = StreamController<Duration>.broadcast();

  late final viewAwarePositionFractionStream = _positionStreamController.stream
      .map((e) => getViewAwareFraction(e).clampNaN(0, 1));

  late final viewAwarePositionStream = _positionStreamController.stream;

  bool isView2(Duration position) =>
      position > getViewAwareDuration(totalDuration);

  Duration getViewAwarePosition(Duration position) => isView2(position)
      ? position - getViewAwareDuration(totalDuration)
      : position;

  double getViewAwareFraction(Duration position) =>
      getViewAwarePosition(position).inMilliseconds /
      getViewAwareDuration(totalDuration).inMilliseconds;

  void switchViews() {
    final total = player.state.duration.inMilliseconds;
    final totalHalf = total ~/ 2;
    final current = player.state.position.inMilliseconds;
    final newPos =
        (current > totalHalf ? current - totalHalf : current + totalHalf)
            .clamp(0, total);

    player.seek(Duration(milliseconds: newPos));
  }

  void viewAwareFractionalSeek(double positionFraction) {
    final actual = getViewAwareDuration(totalDuration);

    player.seek(
      isView2(player.state.position)
          ? actual + actual * positionFraction
          : actual * positionFraction,
    );
  }

  void viewAwareContinuousSeekBy(Duration duration) {
    _continuousSeekPosition ??= getViewAwarePosition(player.state.position);

    _continuousSeekPosition = (_continuousSeekPosition! + duration)
        .clamp(Duration.zero, getViewAwareDuration(totalDuration));

    player.seek(
      isView2(player.state.position)
          ? getViewAwareDuration(totalDuration) + _continuousSeekPosition!
          : _continuousSeekPosition!,
    );

    _positionStreamController.add(_continuousSeekPosition!);
  }

  void stopContinuousSeek() {
    if (_continuousSeekPosition != null) {
      player.seek(
        isView2(player.state.position)
            ? getViewAwareDuration(totalDuration) + _continuousSeekPosition!
            : _continuousSeekPosition!,
      );
    }

    _continuousSeekPosition = null;
  }

  void increaseRate({double by = 0.25, double clamp = 3.0}) {
    player.setRate((player.state.rate + by).clamp(0.25, clamp));
  }

  void decreaseRate({double by = 0.25, double clamp = 3.0}) {
    player.setRate((player.state.rate - by).clamp(0.25, clamp));
  }

  void toggleMute() {
    if (player.state.volume == 0) {
      player.setVolume(_beforeMutingVolume == 0 ? 100 : _beforeMutingVolume);
    } else {
      _beforeMutingVolume = player.state.volume;
      player.setVolume(0);
    }
  }

  void exitFullscreen() {
    defaultExitNativeFullscreen();
    videoWidgetKey.currentState?.exitFullscreen();
  }

  void enterFullscreen() {
    defaultEnterNativeFullscreen();
    videoWidgetKey.currentState?.enterFullscreen();
  }

  void toggleFullscreen() {
    if (videoWidgetKey.currentState?.isFullscreen() ?? false) {
      exitFullscreen();
    } else {
      enterFullscreen();
    }
  }

  void increaseVolume() {
    player.setVolume((player.state.volume + 10).clamp(0, 100));
  }

  void decreaseVolume() {
    player.setVolume((player.state.volume - 10).clamp(0, 100));
  }

  void navigateVideo(BuildContext context, NavigationType type) {
    late final isFullscreen = (_videoKey.currentState?.isFullscreen() ?? false);

    if (kIsWeb && isFullscreen) {
      exitFullscreen();
    }

    VideoNavigateNotification(type).dispatch(context);
  }
}
