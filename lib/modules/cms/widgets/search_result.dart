import 'package:flutter/material.dart';
import 'package:lex/modules/cms/models/search_result.dart';
import 'package:lex/providers/cms.dart';
import 'package:lex/utils/logger.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({super.key, required this.item});

  final CMSSearchResult item;
  @override
  Widget build(BuildContext context) {
    final client = cmsClient();

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
