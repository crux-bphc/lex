import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/impartus/models/subject.dart';
import 'package:go_router/go_router.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject});

  final ImpartusSubject subject;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(subject.subjectName!),
      onTap: () {
        context.push(
          "/impartus/lectures/${subject.subjectId!}/${subject.sessionId}",
        );
      },
    );
  }
}
