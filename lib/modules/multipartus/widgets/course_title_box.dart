import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_tile.dart';
import 'package:lex/providers/local_storage/local_storage.dart';

class CourseTitleBox extends StatelessWidget {
  const CourseTitleBox({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: SizedBox(
        height: 300,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject.prettyCode,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: _RecentlyWatched(
                    subject: subject,
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

class _RecentlyWatched extends StatelessWidget {
  _RecentlyWatched({required this.subject});

  final Subject subject;

  late final _lastWatched =
      GetIt.instance<LocalStorage>().watchHistory.getMostRecentBySubject(
            departmentUrl: subject.departmentUrl,
            code: subject.code,
          );

  @override
  Widget build(BuildContext context) {
    if (_lastWatched == null) {
      return const SizedBox();
    }

    return FutureBuilder(
      future: GetIt.instance<MultipartusService>().fetchLectureVideo(
        department: subject.department,
        code: subject.code,
        ttid: _lastWatched!.$1,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final video = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RECENTLY WATCHED",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 6),
              Expanded(
                child: VideoTile(
                  onPressed: () => context.go(
                    '/multipartus/courses/${subject.departmentUrl}/${subject.code}/watch/${video.ttid}',
                  ),
                  video: video,
                ),
              ),
            ],
          );
        }
        return SizedBox();
      },
    );
  }
}
