import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course});

  final CMSRegisteredCourse course;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        onTap: () {
          context.push('/cms/course/${course.id}');
        },
        title: Text(course.displayname),
        subtitle: Text(course.id.toString()),
      ),
    );
  }
}
