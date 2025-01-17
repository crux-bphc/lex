import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/widgets/seekbar.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/utils/extensions.dart';
import 'package:lex/utils/misc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';

String _getVideoUrl(String baseUrl, String ttid) {
  return '$baseUrl/impartus/ttid/$ttid/m3u8';
}

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
  final _positionUpdateStopwatch = Stopwatch()..start();

  @override
  void initState() {
    super.initState();

    player = Player(
      configuration: PlayerConfiguration(
        ready: () {
          player.seek(widget.startTimestamp);
        },
      ),
    );

    controller = VideoController(player);

    _setup();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
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
    final client = GetIt.instance<LexBackend>().dioClient!;
    final accessToken = Uri.encodeQueryComponent(
      GetIt.instance<AuthProvider>().currentUser.value!.accessToken!,
    );
    late final baseUrl = client.options.baseUrl;

    await player.open(
      Media(
        _getVideoUrl(baseUrl, widget.ttid),
        httpHeaders: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    if (widget.onPositionChanged == null) return;

    _positionStream = player.stream.position.listen((position) {
      final shouldUpdate = mounted &&
          player.state.playing &&
          _positionUpdateStopwatch.elapsed > widget.positionUpdateInterval;

      if (shouldUpdate) {
        widget.onPositionChanged!.call(
          position,
          position.inSeconds / actualDuration(player.state.duration).inSeconds,
        );
        _positionUpdateStopwatch.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final controls = buildDesktopControls(context);
          return SizedBox(
            width: constraints.maxWidth,
            child: AspectRatio(
              aspectRatio: 1280 / 720,
              child: Stack(
                children: [
                  Hero(
                    tag: widget.ttid,
                    createRectTween: (begin, end) =>
                        CurvedRectTween(begin: begin!, end: end!),
                    child: Image.network(
                      "https://a.impartus.com/download1/embedded/thumbnails/${widget.ttid}.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: Theme.of(context)
                          .textTheme
                          .apply(bodyColor: Colors.white),
                    ),
                    child: MaterialDesktopVideoControlsTheme(
                      normal: controls,
                      fullscreen: controls,
                      child: Video(
                        controller: controller,
                        fill: Colors.transparent,
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

VideoController getController(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.controller;

MaterialDesktopVideoControlsThemeData buildDesktopControls(
  BuildContext context,
) {
  return MaterialDesktopVideoControlsThemeData(
    seekBarPositionColor: Theme.of(context).colorScheme.primary,
    seekBarThumbColor: Theme.of(context).colorScheme.primary,
    controlsHoverDuration: 5.seconds,
    hideMouseOnControlsRemoval: true,
    displaySeekBar: false,
    buttonBarHeight: 110,
    seekBarMargin: EdgeInsets.zero,
    seekBarContainerHeight: 8,
    bottomButtonBar: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ImpartusSeekBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PlayPauseButton(),
                _VolumeButton(),
                _ImpartusPositionIndicator(),
                Spacer(),
                _SpeedButton(),
                _SwitchViewButton(),
                if (kIsWeb) _ShareButton(),
                // _PitchButton(),
                _FullscreenButton(),
              ],
            ),
          ],
        ),
      ),
    ],
  );
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

class _VolumeButton extends StatelessWidget {
  const _VolumeButton();

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVolumeButton(
      volumeLowIcon: Icon(LucideIcons.volume_1),
      volumeHighIcon: Icon(LucideIcons.volume_2),
      volumeMuteIcon: Icon(LucideIcons.volume_x),
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

  final _isHovering = signal(false);
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Watch(
          (context) => Text(
            "${_playbackRate()}x",
            style: TextStyle(height: 0),
          ).animate(target: _isHovering() ? 1 : 0).fadeIn(duration: 200.ms),
        ),
        const SizedBox(width: 8),
        MouseRegion(
          onEnter: (_) => _isHovering.value = true,
          onExit: (_) => _isHovering.value = false,
          child: GestureDetector(
            onSecondaryTap: _handleDecreaseSpeed,
            child: MaterialDesktopCustomButton(
              onPressed: _handleIncreaseSpeed,
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
        ),
      ],
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _isHovering.dispose();
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

class _ImpartusSeekBar extends StatefulWidget {
  const _ImpartusSeekBar();

  @override
  State<_ImpartusSeekBar> createState() => _ImpartusSeekBarState();
}

Duration actualDuration(Duration totalDuration) =>
    totalDuration == Duration.zero
        ? const Duration(hours: 1)
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
    );
  }
}
