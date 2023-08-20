import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/modules/impartus/widgets/subject.dart';
import 'package:lex/providers/impartus.dart';

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
        const Expanded(child: _SubjectsList())
      ],
    );
  }
}

class _SubjectsList extends ConsumerWidget {
  const _SubjectsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(impartusSubjectsProvider);
    return courses.when(
      data: (courses) => ListView.builder(
        itemBuilder: (_, i) => SubjectCard(course: courses[i]),
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
