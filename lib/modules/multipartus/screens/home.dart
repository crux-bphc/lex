import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/modules/multipartus/widgets/subject_tile.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:signals/signals_flutter.dart';

class MultipartusHomePage extends StatelessWidget {
  const MultipartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 30, top: 30, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultipartusTitle(),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: _Subjects()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Subjects extends StatefulWidget {
  const _Subjects();

  @override
  State<_Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<_Subjects> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Row(
            children: [
              const Expanded(
                flex: 5,
                child: SearchBar(
                  leading: Icon(
                    LucideIcons.search,
                    size: 20,
                  ),
                  hintText: "Search for any course",
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text("View All Courses"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Watch((context) {
            final subjects = GetIt.instance<MultipartusService>().subjects();
            return subjects.map(
              data: (data) => Scrollbar(
                interactive: true,
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: _SubjectGrid(
                    scrollController: scrollController,
                    subjects: data.values.toList(),
                    onPressed: (subject) {
                      context.go(
                        '/multipartus/courses/${subject.departmentUrl}/${subject.code}',
                      );
                    },
                  ),
                ),
              ),
              error: (e, _) => Text("Error: $e"),
              loading: () => const Center(child: DelayedProgressIndicator()),
            );
          }),
        ),
      ],
    );
  }
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid(
      {required this.subjects,
      required this.onPressed,
      required this.scrollController});

  final List<Subject> subjects;
  final void Function(Subject subject) onPressed;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 208,
          maxCrossAxisExtent: 340,
        ),
        physics: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        itemBuilder: (context, i) => SubjectTile(
          onPressed: () => onPressed(subjects[i]),
          subject: subjects[i],
        ),
        itemCount: subjects.length,
      ),
    );
  }
}
