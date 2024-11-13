import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/course_title_box.dart';
import 'package:lex/modules/multipartus/widgets/filterable_video_grid.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:signals/signals_flutter.dart';

class MultipartusCoursePage extends StatelessWidget {
  const MultipartusCoursePage({
    super.key,
    required String department,
    required String code,
  }) : subjectId = (code: code, department: department);

  final SubjectId subjectId;

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
                SliverPadding(
                  padding: const EdgeInsets.only(top: 30, bottom: 12),
                  sliver: SliverToBoxAdapter(
                    child: CourseTitleBox(subject: subject!),
                  ),
                ),
                _Content(subject: subject),
              ],
            );
          },
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
    return Watch(
      (context) => lectures().map(
        error: (e, s) => SliverToBoxAdapter(child: Text("error $e")),
        loading: () => const SliverFillRemaining(
          child: Center(child: DelayedProgressIndicator()),
        ),
        data: (data) {
          return FilterableVideoGrid(
            professorSessionMap: data.professorSessionMap,
            videos: data.videos,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    lectures.dispose();
    super.dispose();
  }
}
