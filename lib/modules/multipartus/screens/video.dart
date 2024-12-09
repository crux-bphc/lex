import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/backend.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

String _getVideoUrl(String baseUrl, String ttid) {
  return '$baseUrl/impartus/video/$ttid/m3u8';
}

class MultipartusVideoPage extends StatelessWidget {
  const MultipartusVideoPage({
    super.key,
    required this.ttid,
    required this.subjectCode,
    required this.departmentUrl,
  });

  final String subjectCode, departmentUrl, ttid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Player(ttid: ttid),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(top: 20, bottom: 14),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        "UP NEXT IN COURSE",
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    "SLIDES",
                    style: Theme.of(context)
                        .dialogTheme
                        .titleTextStyle!
                        .copyWith(letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Player extends StatefulWidget {
  const _Player({required this.ttid});

  final String ttid;

  @override
  State<_Player> createState() => __PlayerState();
}

class __PlayerState extends State<_Player> {
  late final player = Player(
    configuration: PlayerConfiguration(
      ready: () {
        debugPrint('Player ready');
      },
    ),
  );

  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  void dispose() {
    super.dispose();

    player.dispose();
  }

  @override
  void didUpdateWidget(covariant _Player oldWidget) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.ttid,
      createRectTween: (begin, end) =>
          CurvedRectTween(begin: begin!, end: end!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final controls = buildDesktopControls(context);
            return SizedBox(
              width: constraints.maxWidth,
              child: AspectRatio(
                aspectRatio: 1280 / 720,
                child: MaterialDesktopVideoControlsTheme(
                  normal: controls,
                  fullscreen: controls,
                  child: Video(
                    controller: controller,
                  ),
                ),
              ),
            );
          },
        ),
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
    hideMouseOnControlsRemoval: true,
    displaySeekBar: false,
    buttonBarHeight: 100,
    seekBarMargin: EdgeInsets.zero,
    // bottomButtonBarMargin: EdgeInsets.zero,
    seekBarContainerHeight: 8,
    bottomButtonBar: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MaterialDesktopSeekBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PlayPauseButton(),
                _VolumeButton(),
                Spacer(),
                _SwitchViewButton(),
                _SpeedButton(),
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

class PitchButton extends StatelessWidget {
  const PitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = getController(context);
    return MaterialDesktopCustomButton(
      onPressed: () {
        controller.player
            .setPitch(controller.player.state.pitch == 1.0 ? 1.6 : 1.0);
      },
      icon: Icon(LucideIcons.audio_waveform),
    );
  }
}

class _VolumeButton extends StatelessWidget {
  const _VolumeButton({
    super.key,
  });

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
      icon: Icon(
        isFullscreen(context) ? LucideIcons.minimize : LucideIcons.maximize,
      ),
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton();

  @override
  Widget build(BuildContext context) {
    final controller = getController(context);
    return MaterialDesktopCustomButton(
      onPressed: () {
        final rate = controller.player.state.rate == 1.0 ? 1.75 : 1.0;
        controller.player.setRate(rate);
      },
      icon: Tooltip(
        message: "1.75x",
        child: Icon(LucideIcons.chevrons_right),
      ),
    );
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

class CurvedRectTween extends Tween<Rect> {
  CurvedRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  static const Curve _curve = Curves.easeOutQuad;

  @override
  Rect lerp(double t) {
    return Rect.lerp(
      begin,
      end,
      _curve.transform(t),
    )!;
  }
}
