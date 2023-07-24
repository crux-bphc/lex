import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/models/search_result.dart';
import 'package:ghotpromax/providers/cms.dart';
import 'package:go_router/go_router.dart';

class SearchResult extends ConsumerWidget {
  const SearchResult({super.key, required this.item});

  final CMSSearchResult item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(cmsClientProvider);
    return Card(
      child: ListTile(
        visualDensity: VisualDensity.comfortable,
        titleAlignment: ListTileTitleAlignment.center,
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text(item.professors.join(', ')),
            Text(item.category, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        isThreeLine: true,
        trailing: OutlinedButton.icon(
          onPressed: () {
            client.courseEnroll(item.id).then((success) {
              if (success) {
                context.pushReplacement("/cms/course/${item.id}");
              }
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Enroll"),
        ),
      ),
    );
  }
}
