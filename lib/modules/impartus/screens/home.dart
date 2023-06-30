import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/impartus/widgets/subject.dart';
import 'package:ghotpromax/providers/impartus.dart';

class ImpartusHomePage extends StatelessWidget {
  const ImpartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SubjectsSection();
  }
}

class _SubjectsSection extends StatelessWidget {
  const _SubjectsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Subjects",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 16,
            ),
            const Expanded(child: _SubjectsList())
          ],
        ),
      ),
    );
  }
}

final _subjectsProvider = FutureProvider((ref) {
  final client = ref.watch(impartusClientProvider);
  return client.getSubjects();
});

class _SubjectsList extends ConsumerWidget {
  const _SubjectsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(_subjectsProvider);

    return subjects.when(
      data: (subjects) {
        return ListView(
          children: subjects
              .map((subject) => SubjectCard(subject: subject))
              .toList(growable: false),
        );
      },
      error: (error, _) => Text("$error"),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
