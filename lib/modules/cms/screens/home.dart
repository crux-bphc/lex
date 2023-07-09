import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/providers/cms.dart';
import 'package:go_router/go_router.dart';

class CMSHomePage extends StatelessWidget {
  const CMSHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: const Text("CMS"),
          actions: [
            IconButton(
              onPressed: () {
                context.push('/cms/search');
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                context.push('/cms/downloads');
              },
              icon: const Icon(Icons.download),
            )
          ],
        ),
        const Expanded(child: _RegisteredCourses())
      ],
    );
  }
}

final _registeredCoursesProvider = FutureProvider((ref) {
  final client = ref.watch(cmsClientProvider);
  final user = ref.watch(cmsUser);
  return client.fetchCourses(user.asData!.value.userid!);
});

class _RegisteredCourses extends ConsumerWidget {
  const _RegisteredCourses();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesFuture = ref.watch(_registeredCoursesProvider);

    return coursesFuture.when(
      data: (courses) {
        return ListView.builder(
          itemBuilder: (_, i) {
            return Card(
              clipBehavior: Clip.hardEdge,
              child: ListTile(
                onTap: () {
                  context.go('/cms/course/${courses[i].id}');
                },
                title: Text(courses[i].displayname!),
              ),
            );
          },
          itemCount: courses.length,
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
