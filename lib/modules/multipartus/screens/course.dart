import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/course_title_box.dart';
import 'package:lex/modules/multipartus/widgets/filterable_video_grid.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:signals/signals_flutter.dart';

class MultipartusCoursePage extends StatefulWidget {
  const MultipartusCoursePage({
    super.key,
    required String department,
    required String subjectCode,
  }) : subjectId = (code: subjectCode, department: department);

  final SubjectId subjectId;

  @override
  State<MultipartusCoursePage> createState() => _MultipartusCoursePageState();
}

class _MultipartusCoursePageState extends State<MultipartusCoursePage> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Scrollbar(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Watch(
            (context) {
              final subject = GetIt.instance<MultipartusService>()
                  .subjects()[widget.subjectId];

              return CustomScrollView(
                scrollBehavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                controller: scrollController,
                physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast,
                ),
                slivers: [
                  if (subject != null)
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 30, bottom: 12),
                      sliver: SliverToBoxAdapter(
                        child: CourseTitleBox(subject: subject),
                      ),
                    ),
                  _Content(subjectId: widget.subjectId),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }
}

class _Content extends StatefulWidget {
  const _Content({required this.subjectId});

  final SubjectId subjectId;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late FutureSignal<LecturesResult> lectures = _getLectures();

  FutureSignal<LecturesResult> _getLectures() =>
      GetIt.instance<MultipartusService>().lectures(
        (
          department: widget.subjectId.department,
          code: widget.subjectId.code,
        ),
      );

  @override
  void didUpdateWidget(covariant _Content oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectId != widget.subjectId) {
      lectures.dispose();
      lectures = _getLectures();
    }
  }

  @override
  Widget build(BuildContext context) {
    return lectures.watch(context).map(
          error: (e, s) => SliverToBoxAdapter(child: Text("error $e")),
          loading: () => const SliverFillRemaining(
            child: Center(child: DelayedProgressIndicator()),
          ),
          data: (data) {
            return FilterableVideoGrid(
              professorSessionList: data.professorSessionList,
              videos: data.videos,
              onPressed: (video) => context.go(
                '/multipartus/courses/${widget.subjectId.department.replaceAll('/', ',')}'
                '/${widget.subjectId.code}/watch/${video.ttid}',
              ),
            );
          },
        );
  }

  // commenting this out allows lectures to be cached
  // @override
  // void dispose() {
  //   lectures.dispose();
  //   super.dispose();
  // }
}
