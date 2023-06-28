import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/impartus/widgets/subject.dart';
import 'package:ghotpromax/providers/impartus.dart';

class ImpartusHomePage extends StatelessWidget {
  const ImpartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subjects",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 16),
          const _SubjectsList()
        ],
      ),
    );
  }
}

final _subjectsProvider = FutureProvider((ref) {
  final client = ref.watch(impartusClientProvider);
  return client.getSubjects();
});

class _SubjectsList extends ConsumerWidget {
  const _SubjectsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(_subjectsProvider);

    return subjects.when(
      data: (subjects) {
        return Wrap(
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
