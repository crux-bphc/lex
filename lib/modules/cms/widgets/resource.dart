import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/services/downloads.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';

class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.module});

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
            trailing: module.contents != null
                ? CMSDownloadFile(
                    file: module.contents!,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
