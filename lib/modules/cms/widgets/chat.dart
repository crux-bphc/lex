import 'package:flutter/material.dart';
import 'package:lex/modules/cms/models/course.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ChatModuleCard extends StatelessWidget {
  const ChatModuleCard({super.key, required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.chat_outlined),
        title: Text(module.name),
        subtitle: module.description != null ? Text(module.description!) : null,
        titleTextStyle: Theme.of(context).textTheme.titleSmall,
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () {
            launchUrlString(
              "https://cms.bits-hyderabad.ac.in/mod/chat/view.php?id=${module.id}",
            );
          },
        ),
      ),
    );
  }
}
