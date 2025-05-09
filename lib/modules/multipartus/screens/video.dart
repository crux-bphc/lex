import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/models/video_player_config.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_button.dart';
import 'package:lex/modules/multipartus/widgets/video_player/utils.dart';
import 'package:lex/modules/multipartus/widgets/video_player/video_player.dart';
import 'package:lex/modules/multipartus/widgets/video_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/providers/local_storage/watch_history.dart';
import 'package:lex/widgets/error_bird.dart';
import 'package:lex/widgets/floating_sidebar.dart';
import 'package:lex/widgets/managed_future_builder.dart';
import 'package:signals/signals_flutter.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class MultipartusVideoPage extends StatefulWidget {
  const MultipartusVideoPage({
    super.key,
    required this.ttid,
    this.startTimestamp,
    required this.subjectId,
  });

  final SubjectId subjectId;
  final String ttid;
  final int? startTimestamp;

  @override
  State<MultipartusVideoPage> createState() => _MultipartusVideoPageState();
}

class _MultipartusVideoPageState extends State<MultipartusVideoPage> {
  final config = VideoPlayerConfig();

  Future<VideoPlayerConfigData> _fetchConfig(String ttid) async {
    final service = GetIt.instance<MultipartusService>();
    final result = await service.getAdjacentVideos(
      ttid: ttid,
      count: 1,
    );
    final numViews = await service.getNumAvailableVideoViews(ttid);

    final playbackSpeed =
        GetIt.instance<LocalStorage>().preferences.playbackSpeed();
    final playbackVolume =
        GetIt.instance<LocalStorage>().preferences.playbackVolume();

    return VideoPlayerConfigData(
      previousVideo: result.previous.firstOrNull,
      currentVideo: result.current,
      nextVideo: result.next.firstOrNull,
      playbackSpeed: playbackSpeed,
      playbackVolume: playbackVolume,
      availableViews: numViews,
    );
  }

  void _updateConfigSignal() async {
    final result = await _fetchConfig(widget.ttid);
    config.value = result;
  }

  void _handleNotification(NavigationType navType) async {
    final newTtid = navType == NavigationType.next
        ? config().nextVideo?.ttid
        : config().previousVideo?.ttid;

    if (mounted && newTtid != null) {
      context.go(
        '/multipartus/courses/${widget.subjectId.asUrl}/watch/$newTtid',
      );
    }
  }

  @override
  void didUpdateWidget(covariant MultipartusVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ttid != widget.ttid) {
      _updateConfigSignal();
    }
  }

  @override
  void initState() {
    super.initState();

    _updateConfigSignal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: NotificationListener<VideoNavigateNotification>(
                onNotification: (notification) {
                  _handleNotification(notification.navigationType);

                  // the notification has been handled
                  return true;
                },
                // pass the config signal to the subtree
                child: SignalProvider(
                  create: () => config,
                  child: _LeftSide(
                    ttid: widget.ttid,
                    subjectId: widget.subjectId,
                    startTimestamp: widget.startTimestamp,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _Slides(ttid: widget.ttid),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slides extends StatelessWidget {
  const _Slides({required this.ttid});

  final String ttid;

  void _openImage(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: FractionallySizedBox(
          heightFactor: 0.85,
          widthFactor: 0.85,
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSidebar(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SLIDES",
                style: Theme.of(context)
                    .dialogTheme
                    .titleTextStyle!
                    .copyWith(letterSpacing: 1.5),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: _SlidesView(
              ttid: ttid,
              onImageTap: (url) => _openImage(context, url),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftSide extends StatefulWidget {
  const _LeftSide({
    required this.startTimestamp,
    required this.ttid,
    required this.subjectId,
  });

  final SubjectId subjectId;
  final int? startTimestamp;
  final String ttid;

  @override
  State<_LeftSide> createState() => _LeftSideState();
}

class _LeftSideState extends State<_LeftSide> {
  final _relatedVideoScrollController =
      ScrollController(keepScrollOffset: false);

  late WatchHistoryItem? _lastWatched = _getLastWatchedHistoryItem();

  WatchHistoryItem? _getLastWatchedHistoryItem() =>
      GetIt.instance<LocalStorage>().watchHistory.getByTtid(widget.ttid);

  Duration? _getLastWatchedTimestamp() {
    final d = _lastWatched?.position;

    if (d == null) return null;

    return Duration(seconds: d);
  }

  void _updateWatchHistory(Duration position, double fraction) {
    GetIt.instance<LocalStorage>().watchHistory.update(
          ttid: widget.ttid,
          position: position.inSeconds,
          fraction: fraction,
          code: widget.subjectId.code,
          departmentUrl: widget.subjectId.departmentUrl,
        );
  }

  void _showShortcutsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Keyboard Shortcuts"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Space - Play/Pause"),
            Text("J / Left Arrow - Rewind 10s"),
            Text("L / Right Arrow - Forward 10s"),
            Text("Shift + P - Previous Video"),
            Text("Shift + N - Next Video"),
            Text("Shift + . - Increase Speed"),
            Text("Shift + , - Decrease Speed"),
            Text("M - Mute/Unmute"),
            Text("S - Switch Views"),
            Text("F - Toggle Fullscreen"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _LeftSide oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ttid != widget.ttid) {
      _lastWatched = _getLastWatchedHistoryItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
      builder: (context, scrollController, physics) => CustomScrollView(
        controller: scrollController,
        physics: physics,
        slivers: [
          SliverToBoxAdapter(
            child: VideoPlayer(
              ttid: widget.ttid,
              startTimestamp: (widget.startTimestamp != null
                      ? Duration(seconds: widget.startTimestamp!)
                      : _getLastWatchedTimestamp()) ??
                  Duration.zero,
              onPositionChanged: _updateWatchHistory,
              positionUpdateInterval: Duration(seconds: 2),
            ),
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: VideoTitle(
                    subjectId: widget.subjectId,
                    ttid: widget.ttid,
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 10,
                  child: Row(
                    spacing: 4,
                    children: [
                      _SquareIconButton(
                        onPressed: _showShortcutsDialog,
                        icon: Icon(LucideIcons.info),
                        tooltip: "Keyboard Shortcuts",
                      ),
                      _SquareIconButton(
                        onPressed: () =>
                            _relatedVideoScrollController.position.moveTo(
                          _relatedVideoScrollController.position.pixels - 500,
                          duration: Durations.long4,
                        ),
                        icon: Icon(LucideIcons.chevron_left),
                      ),
                      _SquareIconButton(
                        onPressed: () =>
                            _relatedVideoScrollController.position.moveTo(
                          _relatedVideoScrollController.position.pixels + 500,
                          duration: Durations.long4,
                        ),
                        icon: Icon(LucideIcons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final height =
                  constraints.remainingPaintExtent.clamp(150.0, 190.0);

              return _AdjacentVideos(
                ttid: widget.ttid,
                subjectId: widget.subjectId,
                height: height,
                scrollController: _relatedVideoScrollController,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _relatedVideoScrollController.dispose();
    super.dispose();
  }
}

class _AdjacentVideos extends StatelessWidget {
  const _AdjacentVideos({
    required this.ttid,
    required this.subjectId,
    required this.height,
    required this.scrollController,
  });

  final String ttid;
  final SubjectId subjectId;
  final double height;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ManagedFutureBuilder.sliver(
      future: GetIt.instance<MultipartusService>().getAdjacentVideos(
        ttid: ttid,
        count: 3,
      ),
      data: (adjacent) {
        final videos = [
          ...adjacent.previous.reversed,
          adjacent.current,
          ...adjacent.next.reversed,
        ];

        final currentIndex = adjacent.previous.length;

        return SliverToBoxAdapter(
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                ListView.separated(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final video = videos[index];

                    return AspectRatio(
                      aspectRatio: 400 / 300,
                      child: _buildChild(context, video, index == currentIndex),
                    );
                  },
                  separatorBuilder: (context, _) => SizedBox(width: 12),
                  itemCount: videos.length,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChild(
    BuildContext context,
    ImpartusVideo video,
    bool isCurrent,
  ) =>
      VideoButton(
        video: video,
        titleFontSize: 14,
        dateFontSize: 12,
        lectureNoFontSize: 22,
        gap: 12,
        isCurrentlyWatching: isCurrent,
        onPressed: () async {
          if (scrollController.position.extentBefore > 50) {
            await scrollController.position.moveTo(
              0,
              duration: Durations.long1 *
                  (scrollController.position.extentBefore /
                      scrollController.position.extentTotal),
              curve: Curves.easeInOutQuad,
              clamp: false,
            );
          }
          if (context.mounted) {
            context.go(
              '/multipartus/courses/${subjectId.asUrl}/watch/${video.ttid}',
            );
          }
        },
      );
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final void Function() onPressed;
  final String? tooltip;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.zero,
        iconSize: 20,
        fixedSize: Size.square(28),
        minimumSize: Size.zero,
      ),
    );
  }
}

class _DownloadSlidesButton extends StatefulWidget {
  const _DownloadSlidesButton({required this.ttid});

  final String ttid;

  @override
  State<_DownloadSlidesButton> createState() => __DownloadSlidesButtonState();
}

class __DownloadSlidesButtonState extends State<_DownloadSlidesButton> {
  bool _isEnabled = true;

  Future<void> _downloadSlides() async {
    setState(() {
      _isEnabled = false;
    });
    await GetIt.instance<MultipartusService>().downloadSlides(widget.ttid);
    setState(() {
      _isEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isEnabled ? _downloadSlides : null,
      icon: Icon(Icons.download),
    );
  }
}

class _SlidesView extends StatelessWidget {
  const _SlidesView({required this.ttid, required this.onImageTap});

  final String ttid;
  final void Function(String) onImageTap;

  @override
  Widget build(BuildContext context) {
    return ManagedFutureBuilder(
      future: GetIt.instance<MultipartusService>().fetchSlides(ttid),
      data: (slides) {
        if (slides.isEmpty) {
          return ErrorBird(
            message: "We couldn't find slides for this lecture",
            textAlign: TextAlign.center,
          );
        }

        return ListView.builder(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () => onImageTap(slides[index].url),
              child: Image.network(
                slides[index].url,
                color: Colors.white.withValues(alpha: 0.88),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
          itemCount: slides.length,
        );
      },
    );
  }
}
