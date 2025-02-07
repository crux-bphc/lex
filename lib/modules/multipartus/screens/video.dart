import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/models/video_player_config.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_player.dart';
import 'package:lex/modules/multipartus/widgets/video_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/widgets/error_bird.dart';
import 'package:lex/widgets/floating_sidebar.dart';
import 'package:lex/widgets/managed_future_builder.dart';

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
  late Future<VideoPlayerConfigData> _configFuture;

  Future<VideoPlayerConfigData> _fetchConfig() async {
    return GetIt.instance<MultipartusService>()
        .getVideoPlayerConfig(ttid: widget.ttid);
  }

  void _handleNotification(NavigationType navType) async {
    final config = await _configFuture;

    final newTtid = navType == NavigationType.next
        ? config.nextVideo?.ttid
        : config.previousVideo?.ttid;

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
      setState(() {
        _configFuture = _fetchConfig();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _configFuture = _fetchConfig();
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
                child: FutureBuilder(
                  future: _configFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data;

                    return VideoPlayerConfig(
                      data: data ?? VideoPlayerConfigData(),
                      child: _LeftSide(
                        ttid: widget.ttid,
                        subjectId: widget.subjectId,
                        startTimestamp: widget.startTimestamp,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: FloatingSidebar(
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
                        // _DownloadSlidesButton(ttid: widget.ttid),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(child: _SlidesView(ttid: widget.ttid)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftSide extends StatelessWidget {
  _LeftSide({
    required this.startTimestamp,
    required this.ttid,
    required this.subjectId,
  });

  final SubjectId subjectId;
  final int? startTimestamp;
  final String ttid;

  late final _lastWatched =
      GetIt.instance<LocalStorage>().watchHistory.getByTtid(ttid);

  Duration? _getLastWatchedTimestamp() {
    final d = _lastWatched?.position;

    if (d == null) return null;

    return Duration(seconds: d);
  }

  void _updateWatchHistory(Duration position, double fraction) {
    GetIt.instance<LocalStorage>().watchHistory.update(
          ttid: ttid,
          position: position.inSeconds,
          fraction: fraction,
          code: subjectId.code,
          departmentUrl: subjectId.departmentUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList.list(
          children: [
            VideoPlayer(
              ttid: ttid,
              startTimestamp: (startTimestamp != null
                      ? Duration(seconds: startTimestamp!)
                      : _getLastWatchedTimestamp()) ??
                  Duration.zero,
              onPositionChanged: _updateWatchHistory,
              positionUpdateInterval: Duration(seconds: 2),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: VideoTitle(
                subjectId: subjectId,
                ttid: ttid,
              ),
            ),
          ],
        ),
      ],
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
  const _SlidesView({required this.ttid});

  final String ttid;

  @override
  Widget build(BuildContext context) {
    return ManagedFutureBuilder(
      future: GetIt.instance<MultipartusService>().fetchSlides(ttid),
      data: (slides) {
        if (slides.isEmpty) {
          return ErrorBird(
            message: "We couldn't find slides for this lecture",
          );
        }

        return ListView.builder(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.network(
              slides[index].url,
              color: Colors.white.withValues(alpha: 0.88),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          itemCount: slides.length,
        );
      },
    );
  }
}
