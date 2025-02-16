import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:lex/modules/multipartus/widgets/lecture_title.dart';
import 'package:lex/modules/multipartus/widgets/seekbar.dart';
import 'package:lex/modules/multipartus/widgets/video_player/utils.dart';
import 'package:lex/utils/extensions.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart';
import 'package:signals/signals_flutter.dart';

class VideoNavigationButton extends StatelessWidget {
  const VideoNavigationButton({
    super.key,
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
        iconSize: controlsIconSize,
        icon: icon,
      ),
    );
  }
}

class VolumeButton extends StatefulWidget {
  const VolumeButton({super.key});

  @override
  State<VolumeButton> createState() => VolumeButtonState();
}

class VolumeButtonState extends State<VolumeButton> {
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
        iconSize: controlsIconSize,
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

class FullscreenButton extends StatelessWidget {
  const FullscreenButton({super.key});

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

class SpeedButton extends StatefulWidget {
  const SpeedButton({super.key});

  @override
  State<SpeedButton> createState() => SpeedButtonState();
}

class SpeedButtonState extends State<SpeedButton>
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
          iconSize: controlsIconSize + 4,
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

class SwitchViewButton extends StatelessWidget {
  const SwitchViewButton({super.key});

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

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key});

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

class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

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

class ImpartusSeekBar extends StatefulWidget {
  const ImpartusSeekBar({super.key});

  @override
  State<ImpartusSeekBar> createState() => ImpartusSeekBarState();
}

class ImpartusSeekBarState extends State<ImpartusSeekBar> {
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

class PositionIndicator extends StatefulWidget {
  const PositionIndicator({super.key});

  @override
  State<PositionIndicator> createState() => PositionIndicatorState();
}

class PositionIndicatorState extends State<PositionIndicator>
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
