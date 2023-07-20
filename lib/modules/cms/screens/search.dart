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
        const SizedBox(height: 8.0),
        const Expanded(child: _SearchResults())
      ],
    );
  }
}

final _searchStringProvider = StateProvider.autoDispose((ref) => '');

class _SearchField extends ConsumerWidget {
  const _SearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(labelText: "Course Name"),
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
  const _SearchResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsFuture = ref.watch(_searchResultsProvider);
    return resultsFuture.when(
      data: (results) {
        return ListView.builder(
          itemBuilder: (_, i) {
            return SearchResult(item: results[i]);
          },
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
