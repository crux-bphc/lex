import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';
import 'package:ghotpromax/providers/cms.dart';

class CourseSection extends StatelessWidget {
  const CourseSection({super.key, required this.section});

  final CMSCourseContent section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            section.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ...section.modules.map((module) {
          if (module.modname == "forum") {
            return _ForumModule(module: module);
          } else if (module.modname == "resource") {
            return _ResourceModule(module: module);
          }
          return const Text("WTF");
        })
      ],
    );
  }
}

class _ForumModule extends ConsumerWidget {
  const _ForumModule({required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      child: ExpansionTile(
        title: Text(module.name),
        childrenPadding: const EdgeInsets.symmetric(vertical: 6.0),
        children: [
          LimitedBox(
            maxHeight: MediaQuery.sizeOf(context).height / 2,
            child: _ForumDiscussions(id: module.instance),
          ),
        ],
      ),
    );
  }
}

final _discussionsProvider = FutureProvider.family
    .autoDispose<List<CMSForumDiscussion>, int>((ref, instanceId) {
  final client = ref.watch(cmsClientProvider);
  return client.fetchForum(instanceId);
});

class _ForumDiscussions extends ConsumerWidget {
  const _ForumDiscussions({required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discussionsFuture = ref.watch(_discussionsProvider(id));
    return discussionsFuture.when(
      data: (discussions) {
        return ListView.builder(
          itemBuilder: (_, i) => _ForumDiscussion(discussions[i]),
          itemCount: discussions.length,
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

class _ForumDiscussion extends StatelessWidget {
  const _ForumDiscussion(this.discussion);

  final CMSForumDiscussion discussion;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(discussion.name),
      children: [Text(discussion.message)],
    );
  }
}

class _ResourceModule extends StatelessWidget {
  const _ResourceModule({required this.module});

  final CMSCourseModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(module.name),
      ),
    );
  }
}
