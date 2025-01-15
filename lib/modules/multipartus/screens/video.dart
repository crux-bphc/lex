import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/widgets/video_player.dart';
import 'package:lex/modules/multipartus/widgets/video_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';

class MultipartusVideoPage extends StatelessWidget {
  const MultipartusVideoPage({
    super.key,
    required this.ttid,
    required this.subjectCode,
    required this.department,
    this.startTimestamp,
  });

  final String subjectCode, department, ttid;
  final int? startTimestamp;

  Duration? _getLastWatchedTimestamp() {
    final d = GetIt.instance<LocalStorage>()
        .watchHistory
        .read(int.parse(ttid))
        ?.duration;

    if (d == null) return null;

    return Duration(seconds: d);
  }

  void _updateWatchHistory(Duration position, double fraction) {
    GetIt.instance<LocalStorage>().watchHistory.update(
          int.parse(ttid),
          position.inSeconds,
          fraction,
        );
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
              child: CustomScrollView(
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
                          ttid: ttid,
                        ),
                      ),
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
