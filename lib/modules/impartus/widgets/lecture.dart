import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/impartus/models/subject.dart';
import 'package:go_router/go_router.dart';

class LectureCard extends StatelessWidget {
  const LectureCard({super.key, required this.lecture});

  final ImpartusLecture lecture;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(lecture.topic),
        subtitle: Text(lecture.professorName),
        onTap: () {
          context.go("/impartus/lecture");
        },
      ),
    );
  }
}
