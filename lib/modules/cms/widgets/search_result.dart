import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/models/search_result.dart';
import 'package:ghotpromax/providers/cms.dart';

class SearchResult extends ConsumerWidget {
  const SearchResult({super.key, required this.item});

  final CMSSearchResult item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(cmsClientProvider);
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text("${item.category}\n${item.professors.join(', ')}"),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: () async {
            await client.courseEnroll(item.id);
          },
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}
