import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_player.dart';
import 'package:lex/modules/multipartus/widgets/video_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';

class MultipartusVideoPage extends StatefulWidget {
  const MultipartusVideoPage({
    super.key,
    required this.videoId,
    required this.subjectCode,
    required this.department,
    this.startTimestamp,
  });

  final String subjectCode, department, videoId;
  final int? startTimestamp;

  @override
  State<MultipartusVideoPage> createState() => _MultipartusVideoPageState();
}

class _MultipartusVideoPageState extends State<MultipartusVideoPage> {
  @override
  void initState() {
    super.initState();

    GetIt.instance<MultipartusService>()
        .lectures((code: widget.subjectCode, department: widget.department));
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
              child: FutureBuilder(
                future: GetIt.instance<MultipartusService>()
                    .ttidFromVideoId(widget.videoId),
                builder: (context, snapshot) {
                  final ttid = snapshot.data;

                  return _LeftSide(
                    ttid: ttid,
                    videoId: widget.videoId,
                    subjectCode: widget.subjectCode,
                    department: widget.department,
                    startTimestamp: widget.startTimestamp,
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: Container()),
            // FloatingSidebar(
            //   child: Align(
            //     alignment: AlignmentDirectional.topStart,
            //     child: Text(
            //       "SLIDES",
            //       style: Theme.of(context)
            //           .dialogTheme
            //           .titleTextStyle!
            //           .copyWith(letterSpacing: 1.5),
            //     ),
            //   ),
            // ),
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
    required this.videoId,
    required this.startTimestamp,
    this.ttid,
  });

  final String subjectCode, department, videoId;
  final int? startTimestamp;
  final String? ttid;

  late final _lastWatched =
      GetIt.instance<LocalStorage>().watchHistory.read(int.parse(videoId));

  Duration? _getLastWatchedTimestamp() {
    final d = _lastWatched?.position;

    if (d == null) return null;

    return Duration(seconds: d);
  }

  late final fetchedTtid = ttid ?? _lastWatched?.ttid;

  void _updateWatchHistory(Duration position, double fraction) {
    GetIt.instance<LocalStorage>().watchHistory.update(
          ttid: fetchedTtid!,
          videoId: int.parse(videoId),
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
            fetchedTtid != null
                ? VideoPlayer(
                    ttid: fetchedTtid!,
                    // start with timestamp from link if available or else
                    // get from watch history or else start from beginning
                    startTimestamp: (startTimestamp != null
                            ? Duration(seconds: startTimestamp!)
                            : _getLastWatchedTimestamp()) ??
                        Duration.zero,
                    // update every two seconds
                    onPositionChanged: _updateWatchHistory,
                    positionUpdateInterval: Duration(seconds: 2),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: VideoTitle(
                department: department,
                subjectCode: subjectCode,
                videoId: videoId,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
