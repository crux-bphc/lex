import 'package:flutter/material.dart';
import 'package:ghotpromax/modules/cms/models/search_result.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({super.key, required this.item});

  final CMSSearchResult item;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text("${item.category}\n${item.professors.join(', ')}"),
        isThreeLine: true,
        trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      ),
    );
  }
}
