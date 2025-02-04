import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_player.dart';
import 'package:lex/modules/multipartus/widgets/video_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:lex/widgets/floating_sidebar.dart';

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
  late Future<List<ImpartusVideo>> _lecturesFuture;

  Future<List<ImpartusVideo>> _fetchLectures() async {
    final service = GetIt.instance<MultipartusService>();
    final vid = await service.fetchImpartusVideo(widget.ttid);
    final vids = await service.fetchImpartusVideos(
      (
        sessionId: vid.sessionId,
        subjectId: vid.impartusSubjectId,
      ),
    );
    return vids;
  }

  void _handle(int offset) async {
    final lecs = await _lecturesFuture;
    final index = lecs.indexWhere((e) => e.ttid.toString() == widget.ttid);
    final newLec = lecs.elementAtOrNull((index - offset) % lecs.length);
    final newTtid = newLec?.ttid;

    if (newTtid != null && !mounted) return;
    context.go('/multipartus/courses/${widget.subjectId.asUrl}/watch/$newTtid');
  }

  @override
  void didUpdateWidget(covariant MultipartusVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ttid != widget.ttid) {
      setState(() {
        _lecturesFuture = _fetchLectures();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _lecturesFuture = _fetchLectures();
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
                  _handle(notification.navigationType.offset);

                  return true;
                },
                child: _LeftSide(
                  ttid: widget.ttid,
                  subjectCode: widget.subjectId.code,
                  department: widget.subjectId.department,
                  startTimestamp: widget.startTimestamp,
                  // TODO: please god this needs to change
                  canNavigateNext: true,
                  canNavigatePrevious: true,
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
                        _DownloadSlidesButton(ttid: widget.ttid),
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
    required this.subjectCode,
    required this.department,
    required this.startTimestamp,
    required this.ttid,
    required this.canNavigateNext,
    required this.canNavigatePrevious,
  });

  final String subjectCode, department;
  final int? startTimestamp;
  final String ttid;

  final bool canNavigateNext, canNavigatePrevious;

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
          code: subjectCode,
          departmentUrl: department.replaceAll('/', ','),
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
              canNavigateNext: canNavigateNext,
              canNavigatePrevious: canNavigatePrevious,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: VideoTitle(
                department: department,
                subjectCode: subjectCode,
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
    return FutureBuilder(
      future: GetIt.instance<MultipartusService>().fetchSlides(ttid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: DelayedProgressIndicator());

        final items = snapshot.data!;

        return ListView.builder(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.network(
              items[index].url,
              color: Colors.white.withValues(alpha: 0.88),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          itemCount: snapshot.data!.length,
        );
      },
    );
  }
}
