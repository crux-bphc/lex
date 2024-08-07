import 'package:flutter/material.dart';
import 'package:lex/modules/cms/models/course.dart';
import 'package:lex/modules/cms/widgets/chat.dart';
import 'package:lex/modules/cms/widgets/resource.dart';
import 'package:go_router/go_router.dart';

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
            return _ForumModuleCard(module: module);
          } else if (module.modname == "resource") {
            return ResourceModuleCard(module: module);
          } else if (module.modname == "chat") {
            return ChatModuleCard(module: module);
          }
          return const Text("WTF");
        }),
      ],
    );
  }
}

class _ForumModuleCard extends StatelessWidget {
  const _ForumModuleCard({required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.forum),
        title: Text(module.name),
        onTap: () {
          context.push("/cms/forum/${module.instance}");
        },
      ),
    );
  }
}
