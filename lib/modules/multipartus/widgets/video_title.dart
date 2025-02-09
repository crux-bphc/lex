import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/lecture_title.dart';
import 'package:lex/utils/misc.dart';

class VideoTitle extends StatelessWidget {
  const VideoTitle({
    super.key,
    required this.ttid,
    required this.subjectId,
  });

  final String ttid;
  final SubjectId subjectId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance<MultipartusService>().fetchImpartusVideo(ttid),
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: GetIt.instance<MultipartusService>()
                        .fetchSubject(subjectId),
                    builder: (context, snapshot) {
                      final subject = snapshot.data;

                      final department = subjectId.department;
                      final code = subjectId.code;

                      final name = subject?.name;
                      final append = name != null ? " - $name" : "";
                      final text = "$department $code$append";

                      return Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      );
                    },
                  ),
                ),
                if (snapshot.hasData) ...[
                  SizedBox(width: 3),
                  Text(
                    data!.professor,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            if (data != null) ...[
              LectureTitle(
                lectureNo: data.lectureNo.toString(),
                title: data.title,
              ),
              const SizedBox(height: 3),
              _DateTitle(
                text: formatDate(data.createdAt),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DateTitle extends StatelessWidget {
  const _DateTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: 19,
      ),
    );
  }
}
