import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/widgets/video_player.dart';
import 'package:lex/modules/multipartus/widgets/video_title.dart';

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
                      VideoPlayer(
                        ttid: ttid,
                        startTimestamp: startTimestamp,
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
