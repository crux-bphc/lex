import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/providers/impartus.dart';

class ImpartusLecturesPage extends StatelessWidget {
  const ImpartusLecturesPage({
    super.key,
    required this.subjectId,
    required this.sessionId,
  });

  final String subjectId;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: const BackButton(),
          title: _SubjectName(int.parse(subjectId)),
        ),
        Expanded(
          child: _LectureList(
            subjectId: int.parse(subjectId),
            sessionId: int.parse(sessionId),
          ),
        )
      ],
    );
  }
}

final _subjectNameProvider =
    Provider.autoDispose.family<String, int>((ref, id) {
  final subjects = ref.watch(impartusSubjectsProvider).valueOrNull;
  if (subjects == null) return '';
  final subject = subjects.firstWhere((subject) => subject.subjectId == id);
  return subject.subjectName;
});

class _SubjectName extends ConsumerWidget {
  const _SubjectName(this.id);

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(_subjectNameProvider(id));
    return Text(name);
  }
}

class _LectureList extends ConsumerWidget {
  const _LectureList({required this.subjectId, required this.sessionId});

  final int subjectId;
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Text("Lectures");
  }
}
