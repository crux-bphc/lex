import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';
import 'package:ghotpromax/modules/cms/widgets/course_content.dart';
import 'package:ghotpromax/providers/cms.dart';

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
            Consumer(
              builder: (_, ref, __) {
                return IconButton(
                  onPressed: () {
                    ref.invalidate(_courseContentProvider(numericId));
                  },
                  icon: const Icon(Icons.refresh),
                );
              },
            )
          ],
        ),
        Expanded(child: _ContentList(id: numericId))
      ],
    );
  }
}

class _AppBarTitle extends ConsumerWidget {
  const _AppBarTitle(this.id);

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(courseTitleProvider(id));
    return Text(name);
  }
}

final _courseContentProvider = FutureProvider.family
    .autoDispose<List<CMSCourseContent>, int>((ref, id) async {
  final client = ref.watch(cmsClientProvider);
  return client.fetchCourseContent(id);
});

class _ContentList extends ConsumerWidget {
  const _ContentList({required this.id});

  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentFuture = ref.watch(_courseContentProvider(id));
    return contentFuture.when(
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
    );
  }
}
