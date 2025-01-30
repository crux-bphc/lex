import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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
    required this.subjectCode,
    required this.department,
    this.startTimestamp,
  });

  final String subjectCode, department, ttid;
  final int? startTimestamp;

  @override
  State<MultipartusVideoPage> createState() => _MultipartusVideoPageState();
}

class _MultipartusVideoPageState extends State<MultipartusVideoPage> {
  late Future<List<LectureVideo>> _lecturesFuture;

  @override
  void initState() {
    super.initState();
    _lecturesFuture = _fetchLectures();
  }

  Future<List<LectureVideo>> _fetchLectures() async {
    final service = GetIt.instance<MultipartusService>();
    final result = await service.lectures(
        (department: widget.department, code: widget.subjectCode)).future;
    return result.videos;
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
              child: FutureBuilder<List<LectureVideo>>(
                future: _lecturesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: DelayedProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No lectures found.'));
                  }

                  final lectures = snapshot.data!;
                  final currentIndex = lectures
                      .indexWhere((lecture) => lecture.ttid == widget.ttid);

                  return _LeftSide(
                    ttid: widget.ttid,
                    subjectCode: widget.subjectCode,
                    department: widget.department,
                    startTimestamp: widget.startTimestamp,
                    lectures: lectures,
                    currentIndex: currentIndex,
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: FloatingSidebar(
                child: Column(
                  children: [
                    Text(
                      "SLIDES",
                      style: Theme.of(context)
                          .dialogTheme
                          .titleTextStyle!
                          .copyWith(letterSpacing: 1.5),
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
    required this.lectures,
    required this.currentIndex,
  });

  final String subjectCode, department;
  final int? startTimestamp;
  final String ttid;
  final List<LectureVideo> lectures;
  final int currentIndex;

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

  void _navigateToLecture(BuildContext context, String newTtid) {
    context.go(
      '/multipartus/courses/${department.replaceAll('/', ',')}'
      '/$subjectCode/watch/$newTtid',
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
              lectures: lectures,
              currentIndex: currentIndex,
              onNavigate: (newTtid) => _navigateToLecture(context, newTtid),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: VideoTitle(
                department: department,
                subjectCode: subjectCode,
                ttid: ttid,
              ),
            ),
            if (lectures.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentIndex > 0)
                      ElevatedButton(
                        onPressed: () {
                          final previousLecture = lectures[currentIndex + 1];
                          _navigateToLecture(context, previousLecture.ttid);
                        },
                        child: Text('Previous Lecture'),
                      ),
                    if (currentIndex < lectures.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          final nextLecture = lectures[currentIndex - 1];
                          _navigateToLecture(context, nextLecture.ttid);
                        },
                        child: Text('Next Lecture'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SlidesView extends StatelessWidget {
  const _SlidesView({required this.ttid});

  final String ttid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance<MultipartusService>().slidesBro(ttid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: DelayedProgressIndicator());

        final items = snapshot.data!;

        return ListView.builder(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.network(
              items[index].url,
              color: Colors.white.withOpacity(0.88),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          itemCount: snapshot.data!.length,
        );
      },
    );
  }
}
