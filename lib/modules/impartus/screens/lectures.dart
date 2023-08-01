import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          leading: BackButton(
            onPressed: () {
              context.pop();
            },
          ),
          title: const Text("Course Name"),
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

class _LectureList extends ConsumerWidget {
  const _LectureList({required this.subjectId, required this.sessionId});

  final int subjectId;
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
