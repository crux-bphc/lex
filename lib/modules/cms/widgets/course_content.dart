import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';

class CourseSection extends StatelessWidget {
  const CourseSection({super.key, required this.section});

  final CMSCourseContent section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8.0),
        ...section.modules.map((module) => CourseModule(module: module))
      ],
    );
  }
}

class CourseModule extends StatelessWidget {
  const CourseModule({super.key, required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading:
            Icon(module.modname == "forum" ? Icons.forum : Icons.description),
        title: Text(module.name),
      ),
    );
  }
}
