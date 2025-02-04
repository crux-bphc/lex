import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/utils/misc.dart';

class VideoTitle extends StatelessWidget {
  const VideoTitle({
    super.key,
    required this.subjectCode,
    required this.department,
    required this.ttid,
  });

  final String subjectCode, department, ttid;

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
                    future: GetIt.instance<MultipartusService>().fetchSubject(
                      SubjectId(department: department, code: subjectCode),
                    ),
                    builder: (context, snapshot) {
                      final subject = snapshot.data;

                      final name = subject?.name;
                      final append = name != null ? " - $name" : "";
                      final text = "$department $subjectCode$append";

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
              _LectureTitle(
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

class _LectureTitle extends StatelessWidget {
  const _LectureTitle({
    required this.lectureNo,
    required this.title,
  });

  final String lectureNo, title;
  final double fontSize = 32;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            lectureNo,
            style: TextStyle(
              color: Theme.of(context).colorScheme.surface,
              fontSize: fontSize,
              height: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
