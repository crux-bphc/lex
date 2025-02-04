import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/course_title_box.dart';
import 'package:lex/modules/multipartus/widgets/filter_dropdown.dart';
import 'package:lex/modules/multipartus/widgets/filterable_video_grid.dart';
import 'package:lex/widgets/bird.dart';
import 'package:lex/widgets/managed_future_builder.dart';
import 'package:signals/signals_flutter.dart';

class MultipartusCoursePage extends StatefulWidget {
  const MultipartusCoursePage({
    super.key,
    required this.subjectId,
  });

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
          child: FutureBuilder(
            future: GetIt.instance<MultipartusService>()
                .fetchSubject(widget.subjectId),
            builder: (context, snapshot) {
              final subject = snapshot.data;

              return CustomScrollView(
                scrollBehavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                controller: scrollController,
                physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.fast,
                ),
                slivers: [
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
  late final selected = signal<SectionSession?>(null);

  void _onPressed(BuildContext context, LectureVideo video) {
    context.go(
      "/multipartus/courses/${widget.subjectId.departmentUrl}"
      "/${widget.subjectId.code}/watch/${video.ttid}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverManagedFutureBuilder(
      future: GetIt.instance<MultipartusService>()
          .lectureSections(widget.subjectId),
      data: (sections) {
        if (sections.isEmpty) {
          return ErrorBird(message: "No sections found for this subject");
        }
        return Watch(
          (context) => SliverMainAxisGroup(
            slivers: [
              _FilterSliver(
                sessionList: sections,
                onSelected: (s) => selected.value = s,
                selected: selected() ?? sections.first,
              ),
              _VideoGridSliver(
                selectedSession: selected() ?? sections.first,
                onPressed: (v) => _onPressed(context, v),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterSliver extends StatelessWidget {
  const _FilterSliver({
    required this.sessionList,
    required this.onSelected,
    required this.selected,
  });

  final List<SectionSession> sessionList;
  final void Function(SectionSession) onSelected;
  final SectionSession selected;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: FilterDropdown(
          items: sessionList,
          onSelected: onSelected,
          selected: selected,
        ),
      ),
    );
  }
}

class _VideoGridSliver extends StatelessWidget {
  const _VideoGridSliver({
    required this.selectedSession,
    required this.onPressed,
  });

  final SectionSession selectedSession;
  final void Function(LectureVideo video) onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverManagedFutureBuilder(
      future: GetIt.instance<MultipartusService>()
          .fetchLectureVideos(selectedSession.section),
      data: (lecs) => VideoGrid(
        videos: lecs,
        onPressed: onPressed,
      ),
    );
  }
}
