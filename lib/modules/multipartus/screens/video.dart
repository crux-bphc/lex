import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_player.dart';
import 'package:lex/modules/multipartus/widgets/video_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/widgets/floating_sidebar.dart';

class MultipartusVideoPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Builder(
                builder: (context) {
                  final ttid = GetIt.instance<MultipartusService>()
                      .ttidFromVideoId(videoId);
                  return ttid != null
                      ? _LeftSide(
                          ttid: ttid,
                          videoId: videoId,
                          subjectCode: subjectCode,
                          department: department,
                          startTimestamp: startTimestamp,
                        )
                      : Text(
                          "I'm sorry man it just doesn't work."
                          " It will soon though.",
                        );
                },
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: FloatingSidebar(
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

class _LeftSide extends StatelessWidget {
  const _LeftSide({
    required this.ttid,
    required this.subjectCode,
    required this.department,
    required this.videoId,
    required this.startTimestamp,
  });

  final String ttid;
  final String subjectCode, department, videoId;
  final int? startTimestamp;

  Duration? _getLastWatchedTimestamp() {
    final d = GetIt.instance<LocalStorage>()
        .watchHistory
        .read(int.parse(videoId))
        ?.position;

    if (d == null) return null;

    return Duration(seconds: d);
  }

  void _updateWatchHistory(Duration position, double fraction) {
    GetIt.instance<LocalStorage>().watchHistory.update(
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
            VideoPlayer(
              ttid: ttid,
              // start with timestamp from link if available or else
              // get from watch history or else start from beginning
              startTimestamp: (startTimestamp != null
                      ? Duration(seconds: startTimestamp!)
                      : _getLastWatchedTimestamp()) ??
                  Duration.zero,
              // update every two seconds
              onPositionChanged: _updateWatchHistory,
              positionUpdateInterval: Duration(seconds: 2),
            ),
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
