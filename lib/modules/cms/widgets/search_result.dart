import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/modules/cms/models/search_result.dart';
import 'package:lex/providers/cms.dart';
import 'package:lex/utils/logger.dart';

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
              logger.i("Enrolled in ${item.name}: $success");
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Enroll"),
        ),
      ),
    );
  }
}
