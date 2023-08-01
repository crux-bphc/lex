import 'package:flutter/material.dart';
import 'package:ghotpromax/logger.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';

class ResourceModule extends StatelessWidget {
  const ResourceModule({super.key, required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(module.name),
            trailing: IconButton(
              onPressed: () {
                logger.w("Have to implement download manager");
              },
              icon: const Icon(Icons.download),
            ),
          ),
        ],
      ),
    );
  }
}
