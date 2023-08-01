import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/impartus/widgets/course.dart';
import 'package:ghotpromax/providers/impartus.dart';

class ImpartusHomePage extends StatelessWidget {
  const ImpartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Impartus"),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.download),
            )
          ],
        ),
        const Expanded(child: _CourseList())
      ],
    );
  }
}

final _coursesProvider = FutureProvider((ref) {
  final client = ref.watch(impartusClientProvider);
  return client.fetchCourses();
});

class _CourseList extends ConsumerWidget {
  const _CourseList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(_coursesProvider);
    return courses.when(
      data: (courses) => ListView.builder(
        itemBuilder: (_, i) => CourseCard(course: courses[i]),
        itemCount: courses.length,
      ),
      error: (error, trace) => Center(
        child: Text("$error\n$trace"),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
