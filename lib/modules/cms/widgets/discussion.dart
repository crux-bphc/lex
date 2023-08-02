import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/cms/models/course.dart';
import 'package:ghotpromax/modules/cms/models/forum.dart';
import 'package:ghotpromax/providers/cms.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DiscussionCard extends StatelessWidget {
  const DiscussionCard({super.key, required this.discussion});

  final CMSForumDiscussion discussion;

  String getDate() {
    final time = DateTime.fromMillisecondsSinceEpoch(discussion.created * 1000);
    return "${time.day}/${time.month}/${time.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        title: Text(discussion.name),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(discussion.userfullname),
            Text(
              getDate(),
              style: Theme.of(context).textTheme.labelMedium,
            )
          ],
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.topLeft,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        children: [
          Text(
            discussion.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(),
          for (final file in discussion.attachments) _Attachment(file),
          if (discussion.attachments.isNotEmpty) const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  launchUrlString(
                    "https://cms.bits-hyderabad.ac.in/mod/forum/discuss.php?d=${discussion.discussion}",
                  );
                },
                icon: const Icon(Icons.open_in_browser),
                tooltip: "Open in Browser",
              )
            ],
          )
        ],
      ),
    );
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment(this.file);

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(file.filename),
      visualDensity: VisualDensity.compact,
      trailing: _DownloadButton(file),
    );
  }
}

class _DownloadButton extends ConsumerWidget {
  const _DownloadButton(this.file);

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(cmsClientProvider);
    return IconButton(
      onPressed: () {
        client.download(file);
      },
      icon: const Icon(Icons.download),
    );
  }
}
