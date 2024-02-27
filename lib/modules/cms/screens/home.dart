import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lex/modules/cms/widgets/course.dart';
import 'package:lex/providers/cms.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

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
                context.push('/cms/forum/1');
              },
              icon: const Icon(Icons.public),
              tooltip: "Site Annoucements",
            ),
            IconButton(
              onPressed: () {
                registeredCourses.refresh();
              },
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () {
                context.push('/cms/search');
              },
              icon: const Icon(Icons.search),
            ),
            if (!kIsWeb)
              IconButton(
                onPressed: () {
                  context.push('/cms/downloads');
                },
                icon: const Icon(Icons.download),
              ),
          ],
        ),
        const Expanded(child: _RegisteredCourses()),
      ],
    );
  }
}

class _RegisteredCourses extends StatelessWidget {
  const _RegisteredCourses();

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => registeredCourses.value.map(
        data: (courses) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (_, i) => CourseCard(course: courses[i]),
            itemCount: courses.length,
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
