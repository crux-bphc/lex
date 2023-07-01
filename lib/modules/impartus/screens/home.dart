import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/impartus/models/subject.dart';
import 'package:ghotpromax/modules/impartus/widgets/subject.dart';
import 'package:ghotpromax/providers/impartus.dart';

class ImpartusHomePage extends StatelessWidget {
  const ImpartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SubjectsSection();
  }
}

final _subjectsProvider = FutureProvider((ref) {
  final client = ref.watch(impartusClientProvider);
  return client.getSubjects();
});

class _SubjectsSection extends ConsumerWidget {
  const _SubjectsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(_subjectsProvider);

    return subjects.when(
      data: (subjects) {
        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text("Subjects"),
            ),
            _SubjectsList(subjects)
          ],
        );
      },
      error: (error, _) => Text("$error"),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _SubjectsList extends StatelessWidget {
  const _SubjectsList(this.subjects);

  final List<ImpartusSubject> subjects;
  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: subjects
          .map((subject) => SubjectCard(subject: subject))
          .toList(growable: false),
    );
  }
}
