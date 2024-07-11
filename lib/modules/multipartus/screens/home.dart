import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/modules/multipartus/widgets/subject_tile.dart';
import 'package:signals/signals_flutter.dart';

class MultipartusHomePage extends StatelessWidget {
  const MultipartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MultipartusTitle(),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _Subjects()),
                SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Subjects extends StatelessWidget {
  const _Subjects();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
        const SizedBox(height: 20),
        Expanded(
          child: Watch((context) {
            final subjects = GetIt.instance<MultipartusService>().subjects();
            return subjects.map(
              data: (data) => _SubjectGrid(
                subjects: data.values.toList(),
                onPressed: (id) {
                  context.go('/multipartus/courses/${id.routeId}');
                },
              ),
              error: (e, _) => Text("Error: $e"),
              loading: () => const Center(child: CircularProgressIndicator()),
            );
          }),
        ),
      ],
    );
  }
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid({required this.subjects, required this.onPressed});

  final List<Subject> subjects;
  final void Function(SubjectId id) onPressed;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 208,
        maxCrossAxisExtent: 340,
      ),
      itemBuilder: (context, i) => SubjectTile(
        onPressed: () => onPressed(subjects[i].id),
        subject: subjects[i],
      ),
      itemCount: subjects.length,
    );
  }
}
