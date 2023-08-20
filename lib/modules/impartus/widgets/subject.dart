import 'package:flutter/material.dart';
import 'package:lex/modules/impartus/models/subject.dart';
import 'package:go_router/go_router.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.course});

  final ImpartusSubject course;

  @override
  Widget build(BuildContext context) {
    final [subjectName, subjectCode, ...details] =
        course.subjectName.split(" ");

    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: Text("$subjectName $subjectCode"),
        subtitle: Text(
          details.join(" "),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        onTap: () {
          context.push(
            "/impartus/lectures/${course.subjectId}/${course.sessionId}",
          );
        },
      ),
    );
  }
}
