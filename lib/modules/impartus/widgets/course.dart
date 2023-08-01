import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/impartus/models/course.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course});

  final ImpartusCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: Text(course.subjectName),
        onTap: () {
          context.push(
            "/impartus/lectures/${course.subjectId}/${course.sessionId}",
          );
        },
      ),
    );
  }
}
