import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/modules/cms/models/forum.dart';
import 'package:lex/modules/cms/widgets/discussion.dart';
import 'package:lex/providers/cms.dart';

class CMSForumPage extends StatelessWidget {
  const CMSForumPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: const BackButton(),
        ),
        Expanded(child: _Discussions(id: int.parse(id)))
      ],
    );
  }
}

final _discussionsProvider =
    FutureProvider.autoDispose.family<List<CMSForumDiscussion>, int>(
  (ref, id) async {
    final client = ref.watch(cmsClientProvider);
    return await client.fetchForum(id);
  },
);

class _Discussions extends ConsumerWidget {
  const _Discussions({required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discussions = ref.watch(_discussionsProvider(id));
    return discussions.when(
      data: (discussions) => ListView.builder(
        itemBuilder: (_, i) => DiscussionCard(
          discussion: discussions[i],
        ),
        itemCount: discussions.length,
      ),
      error: (error, trace) => Center(
        child: Text("$error\n$trace"),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
