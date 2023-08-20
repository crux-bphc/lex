import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/modules/impartus/models/subject.dart';
import 'package:lex/modules/impartus/widgets/lecture.dart';
import 'package:lex/providers/impartus.dart';

class ImpartusLecturesPage extends StatelessWidget {
  const ImpartusLecturesPage({
    super.key,
    required this.subjectId,
    required this.sessionId,
  });

  final int subjectId;
  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: const BackButton(),
          title: _SubjectName(subjectId),
        ),
        Expanded(
          child: _LectureList(
            subjectId: subjectId,
            sessionId: sessionId,
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

final _lectureProvider =
    FutureProvider.autoDispose.family<List<ImpartusLecture>, String>((ref, id) {
  final client = ref.watch(impartusClientProvider);
  final [subjectId, sessionId] = id.split("-");

  return client.getLectures(int.parse(subjectId), int.parse(sessionId));
});

class _LectureList extends ConsumerWidget {
  const _LectureList({required this.subjectId, required this.sessionId});

  final int subjectId;
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lectures = ref.watch(_lectureProvider("$subjectId-$sessionId"));

    return lectures.when(
      data: (lectures) => ListView.builder(
        itemBuilder: (_, i) => LectureCard(lecture: lectures[i]),
        itemCount: lectures.length,
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
