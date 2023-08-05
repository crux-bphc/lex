import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';

class ChatModuleCard extends StatelessWidget {
  const ChatModuleCard({super.key, required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.chat_outlined),
        title: Text(module.name),
        titleTextStyle: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
