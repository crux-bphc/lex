import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/utils/logger.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';
import 'package:ghotpromax/providers/cms.dart';

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
            trailing: Consumer(
              builder: (context, ref, child) {
                final client = ref.watch(cmsClientProvider);
                return IconButton(
                  onPressed: () async {
                    final success = await client.download(module.contents!);
                    if (success) {
                      logger.i("File downloaded successfully");
                    } else {
                      logger.w("Could not download file");
                    }
                  },
                  icon: const Icon(Icons.download),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
