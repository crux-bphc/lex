import 'package:flutter/material.dart';
import 'package:lex/modules/cms/models/course.dart';
import 'package:lex/modules/cms/widgets/course_content.dart';
import 'package:lex/providers/cms.dart';
import 'package:lex/utils/signals.dart';
import 'package:signals/signals_flutter.dart';

class CMSCoursePage extends StatelessWidget {
  const CMSCoursePage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final numericId = int.parse(id);

    return Column(
      children: [
        AppBar(
          leading: const BackButton(),
          title: _AppBarTitle(numericId),
          actions: [
            IconButton(
              onPressed: () {
                _courseContent(numericId).refresh();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        Expanded(child: _ContentList(id: numericId)),
      ],
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle(this.id);

  final int id;

  @override
  Widget build(BuildContext context) {
    final name = courseTitle(id);
    return Watch((context) => Text(name.value));
  }
}

final _courseContent = asyncSignalContainer<List<CMSCourseContent>, int>(
  (id) => computedAsync(() => cmsClient().fetchCourseContent(id)),
  cache: true,
);

class _ContentList extends StatelessWidget {
  const _ContentList({required this.id});

  final int id;
  @override
  Widget build(BuildContext context) {
    final content = _courseContent(id);

    return Watch(
      (context) => content.value.map(
        data: (content) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (_, i) => CourseSection(section: content[i]),
            separatorBuilder: (_, __) => const Divider(height: 16.0),
            itemCount: content.length,
          );
        },
        error: (error, trace) => Center(
          child: Text("$error\n$trace"),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
