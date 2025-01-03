import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/seekbar.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/backend.dart';
import 'package:lex/utils/extensions.dart';
import 'package:lex/utils/misc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:signals/signals_flutter.dart';

String _getVideoUrl(String baseUrl, String ttid) {
  return '$baseUrl/impartus/video/$ttid/m3u8';
}

class MultipartusVideoPage extends StatelessWidget {
  const MultipartusVideoPage({
    super.key,
    required this.ttid,
    required this.subjectCode,
    required this.department,
  });

  final String subjectCode, department, ttid;

  @override
  Widget build(BuildContext context) {
    final startTimestamp =
        int.tryParse(Uri.base.queryParameters['t'] ?? '0') ?? 0;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: CustomScrollView(
                slivers: [
                  SliverList.list(
                    children: [
                      _Player(
                        ttid: ttid,
                        startTimestamp: startTimestamp,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _Title(
                          department: department,
                          subjectCode: subjectCode,
                          ttid: ttid,
                        ),
                      ),
                      // Divider(
                      //   color: Theme.of(context).colorScheme.onInverseSurface,
                      //   thickness: 2,
                      //   height: 20,
                      // ),
                      // const SizedBox(height: 10),
                      // Text(
                      //   "UP NEXT IN COURSE",
                      //   style: TextStyle(
                      //     letterSpacing: 1.5,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                    ],
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
  const _Player({required this.ttid, required this.startTimestamp});

  final String ttid;
  final int startTimestamp;

  @override
  State<_Player> createState() => __PlayerState();
}

class __PlayerState extends State<_Player> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();

    player = Player(
      configuration: PlayerConfiguration(
        ready: () {
          debugPrint('Player ready');
          player.seek(Duration(seconds: widget.startTimestamp));
        },
      ),
    );

    controller = VideoController(player);
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
                  MaterialDesktopVideoControlsTheme(
                    normal: controls,
                    fullscreen: controls,
                    child: Video(
                      controller: controller,
                      fill: Colors.transparent,
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
                _SwitchViewButton(),
                _SpeedButton(),
                // _PitchButton(),
                if (kIsWeb) _ShareButton(),
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

class _ImpartusSeekBar extends StatefulWidget {
  const _ImpartusSeekBar();

  @override
  State<_ImpartusSeekBar> createState() => _ImpartusSeekBarState();
}

Duration actualDuration(Duration totalDuration) => totalDuration * 0.5;

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

class _Title extends StatefulWidget {
  const _Title({
    required this.subjectCode,
    required this.department,
    required this.ttid,
  });

  final String subjectCode, department, ttid;

  @override
  State<_Title> createState() => _TitleState();
}

class _TitleState extends State<_Title> {
  late final subject = GetIt.instance<MultipartusService>().subjects.select(
        (s) => s()[(department: widget.department, code: widget.subjectCode)],
      );

  @override
  void initState() {
    super.initState();

    // TODO: temp, replace with subject endpoint
    GetIt.instance<MultipartusService>().pinnedSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Watch(
          (context) {
            final name = subject()?.name;
            final append = name != null ? " - $name" : "";
            final text = "${widget.department} ${widget.subjectCode}$append";

            return _CoolCoolTitle(text: text);
          },
        ),
        const SizedBox(height: 5),
        FutureBuilder(
          future: GetIt.instance<MultipartusService>().fetchLectureVideo(
            department: widget.department,
            code: widget.subjectCode,
            ttid: int.parse(widget.ttid),
          ),
          builder: (context, snapshot) {
            final data = snapshot.data;
            debugPrint(data == null ? "null" : "not null");
            return data != null
                ? _CoolTitle(
                    leading: data.lectureNo.toString(),
                    title: data.title,
                    subtitle: data.professor,
                    trailing: formatDate(data.createdAt),
                  )
                : Container();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    subject.dispose();

    super.dispose();
  }
}

// TODO: give the next two widgets better names
class _CoolCoolTitle extends StatelessWidget {
  const _CoolCoolTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onInverseSurface,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}

class _CoolTitle extends StatelessWidget {
  const _CoolTitle({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String leading, title, subtitle, trailing;
  final double fontSize = 32;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          TextSpan(
            children: [
              WidgetSpan(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    leading,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: fontSize,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
              ),
              TextSpan(
                text: title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                LucideIcons.user_round,
                size: 20,
              ),
              label: Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            Spacer(),
            Text(
              trailing,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
