import 'package:flutter/material.dart';
import 'package:lex/modules/cms/models/course.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course});

  final CMSRegisteredCourse course;

  @override
  Widget build(BuildContext context) {
    final [name, code, ...details] = course.displayname.split(" ");

    return Card(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        onTap: () {
          context.push('/cms/course/${course.id}');
        },
        title: Text("$name $code"),
        subtitle: Text(
          details.join(" "),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}
