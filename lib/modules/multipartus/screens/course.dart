import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/lecture_section.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/widgets/back_button_wrapper.dart';
import 'package:signals/signals_flutter.dart';

class MultipartusCoursePage extends StatelessWidget {
  const MultipartusCoursePage({super.key, required this.subjectId});

  final SubjectId subjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackButtonWrapper(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Watch((context) {
                final subject = GetIt.instance<MultipartusService>()
                    .pinnedSubjects()
                    .value?[subjectId];

                return _CourseTitleBox(subject: subject!);
              }),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20),
              sliver: _Content(id: subjectId),
            ),
          ],
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
  const _Content({required this.id});

  final SubjectId id;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late final lectures =
      GetIt.instance<MultipartusService>().lectureSections(widget.id);

  @override
  Widget build(BuildContext context) {
    return lectures.watch(context).map(
          error: (e, s) => SliverToBoxAdapter(child: Text("error $e")),
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          data: (data) => _LectureSectionGrid(lectureSections: data),
        );
  }
}

class _LectureSectionGrid extends StatelessWidget {
  const _LectureSectionGrid({required this.lectureSections});

  final List<LectureSection> lectureSections;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 208,
        maxCrossAxisExtent: 340,
      ),
      itemBuilder: (context, i) {
        return _LectureSectionTile(
          lectureSection: lectureSections[i],
          onPressed: () {},
        );
      },
      itemCount: lectureSections.length,
    );
  }
}

class _LectureSectionTile extends StatelessWidget {
  const _LectureSectionTile({
    required this.onPressed,
    required this.lectureSection,
  });

  final LectureSection lectureSection;

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "L${lectureSection.section}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.secondaryFixed,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft + const Alignment(0, -0.2),
              child: Text(
                lectureSection.professor,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
