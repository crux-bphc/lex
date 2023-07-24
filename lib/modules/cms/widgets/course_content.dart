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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            section.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ...section.modules.map((module) {
          if (module.modname == "forum") {
            return ForumModule(module: module);
          } else if (module.modname == "resource") {
            return ResourceModule(module: module);
          }
          return const Text("WTF");
        })
      ],
    );
  }
}

class ForumModule extends StatelessWidget {
  const ForumModule({super.key, required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.forum),
        title: Text(module.name),
      ),
    );
  }
}

class ResourceModule extends StatelessWidget {
  const ResourceModule({super.key, required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(module.name),
      ),
    );
  }
}
