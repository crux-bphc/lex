import 'package:flutter/material.dart';
import 'package:lex/modules/cms/widgets/search_result.dart';
import 'package:lex/providers/cms.dart';
import 'package:signals/signals_flutter.dart';

class CMSSearchPage extends StatelessWidget {
  const CMSSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: const BackButton(),
          title: const Text("Search"),
        ),
        const _SearchField(),
        const SizedBox(height: 12.0),
        const Expanded(child: _SearchResults()),
      ],
    );
  }
}

final _searchString = signal('no balls');

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: "Course Name",
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (value) {
        _searchString.value = value;
      },
    );
  }
}

final _searchResults =
    computedAsync(() => cmsClient().searchCourses(_searchString.value));

class _SearchResults extends StatelessWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => _searchResults.value.map(
        data: (results) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (_, i) => SearchResult(item: results[i]),
            itemCount: results.length,
          );
        },
        error: (error, trace) => Center(
          child: Text("$error\n$trace"),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
