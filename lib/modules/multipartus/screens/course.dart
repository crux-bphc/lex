import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/widgets/auto_tooltip_text.dart';
import 'package:signals/signals_flutter.dart';

final _dateFormat = DateFormat.yMMMd().add_jm();

class MultipartusCoursePage extends StatelessWidget {
  const MultipartusCoursePage({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Watch(
          (context) {
            final subject = GetIt.instance<MultipartusService>()
                .subjects()
                .value?[subjectId];

            return CustomScrollView(
              slivers: [
                const SliverPadding(padding: EdgeInsets.only(top: 30)),
                SliverToBoxAdapter(
                  child: _CourseTitleBox(subject: subject!),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20),
                  sliver: _Content(
                    subject: subject,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CourseTitleBox extends StatelessWidget {
  const _CourseTitleBox({required this.subject});

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
            const Expanded(child: Placeholder()),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({required this.subject});

  final Subject subject;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late final lectures = GetIt.instance<MultipartusService>().lectures(
    departmentUrl: widget.subject.departmentUrl,
    code: widget.subject.code,
  );

  @override
  Widget build(BuildContext context) {
    return lectures.watch(context).map(
          error: (e, s) => SliverToBoxAdapter(child: Text("error $e")),
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          data: (data) => _ImpartusVideoGrid(videos: data),
        );
  }
}

class _ImpartusVideoGrid extends StatelessWidget {
  const _ImpartusVideoGrid({required this.videos});

  final List<LectureVideo> videos;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 225,
        maxCrossAxisExtent: 400,
      ),
      itemBuilder: (context, i) {
        return _VideoTile(
          video: videos[i],
          onPressed: () {},
        );
      },
      itemCount: videos.length,
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.onPressed,
    required this.video,
  });

  final LectureVideo video;

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(flex: 7, child: Placeholder()),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoTooltipText(
                    text:
                        "Lecture ${video.video.lectureNo}: ${video.video.topic}",
                    tooltipText: video.video.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    _dateFormat.format(video.video.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
