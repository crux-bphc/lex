import 'package:flutter/material.dart';
import 'package:lex/modules/cms/models/forum.dart';
import 'package:lex/modules/cms/widgets/discussion.dart';
import 'package:lex/providers/cms.dart';
import 'package:lex/utils/signals.dart';
import 'package:signals/signals_flutter.dart';

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
        Expanded(child: _Discussions(id: int.parse(id))),
      ],
    );
  }
}

final _discussions = asyncSignalContainer<List<CMSForumDiscussion>, int>(
  (id) => computedAsync(() => cmsClient().fetchForum(id)),
  cache: true,
);

class _Discussions extends StatelessWidget {
  const _Discussions({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final discussions = _discussions(id);

    return Watch(
      (context) => discussions.value.map(
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
      ),
    );
  }
}
