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
    return Column(
      children: [
        AppBar(
          leading: const BackButton(),
          title: Text("Course ID: $id"),
        ),
        Expanded(child: _ContentList(id: int.parse(id)))
      ],
    );
  }
}

final _courseContentProvider = FutureProvider.autoDispose
    .family<List<CMSCourseContent>, int>((ref, id) async {
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
        return ListView.builder(
          itemBuilder: (_, i) {
            return CourseSection(section: content[i]);
          },
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
