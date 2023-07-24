import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/widgets/search_result.dart';
import 'package:ghotpromax/providers/cms.dart';

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
        const Expanded(child: _SearchResults())
      ],
    );
  }
}

final _searchStringProvider = StateProvider.autoDispose((ref) => 'no balls');

class _SearchField extends ConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        labelText: "Course Name",
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (value) {
        ref.read(_searchStringProvider.notifier).state = value;
      },
    );
  }
}

final _searchResultsProvider = FutureProvider.autoDispose((ref) {
  final searchFor = ref.watch(_searchStringProvider);
  final client = ref.watch(cmsClientProvider);
  return client.searchCourses(searchFor);
});

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsFuture = ref.watch(_searchResultsProvider);
    return resultsFuture.when(
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
    );
  }
}
