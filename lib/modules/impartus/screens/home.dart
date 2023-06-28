import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/impartus/models/subject.dart';
import 'package:ghotpromax/providers/impartus.dart';

final _subjectsProvider = FutureProvider((ref) {
  final client = ref.watch(impartusClientProvider);
  return client.getSubjects();
});

class ImpartusHomePage extends ConsumerWidget {
  const ImpartusHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(_subjectsProvider);
    return subjects.when(
      data: (subjects) {
        return Column(
          children: [
            Text(
              "Subjects",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            _SubjectsList(subjects: subjects)
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
  const _SubjectsList({super.key, required this.subjects});

  final List<ImpartusSubject> subjects;

  @override
  Widget build(BuildContext context) {
    return const Text("Subjects");
  }
}
