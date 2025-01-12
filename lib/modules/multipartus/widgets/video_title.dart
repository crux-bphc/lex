import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/utils/misc.dart';
import 'package:signals/signals_flutter.dart';

class VideoTitle extends StatefulWidget {
  const VideoTitle({
    super.key,
    required this.subjectCode,
    required this.department,
    required this.ttid,
  });

  final String subjectCode, department, ttid;

  @override
  State<VideoTitle> createState() => _TitleState();
}

class _TitleState extends State<VideoTitle> {
  late final subject = GetIt.instance<MultipartusService>().subjects.select(
        (s) => s()[(department: widget.department, code: widget.subjectCode)],
      );

  @override
  void initState() {
    super.initState();

    // TODO: temp, replace with subject endpoint
    GetIt.instance<MultipartusService>().pinnedSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance<MultipartusService>().fetchLectureVideo(
        department: widget.department,
        code: widget.subjectCode,
        ttid: int.parse(widget.ttid),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Watch(
                    (context) {
                      final name = subject()?.name;
                      final append = name != null ? " - $name" : "";
                      final text =
                          "${widget.department} ${widget.subjectCode}$append";

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
                          .withOpacity(0.7),
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

  @override
  void dispose() {
    subject.dispose();

    super.dispose();
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
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
