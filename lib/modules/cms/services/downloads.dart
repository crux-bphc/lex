import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/modules/cms/models/course.dart';
import 'package:lex/providers/cms.dart';
import 'package:lex/utils/logger.dart';

final _downloadedFiles = StateProvider<ISet<String>>((ref) => ISet());

class CMSDownloadFile extends ConsumerWidget {
  const CMSDownloadFile({
    super.key,
    required this.file,
  });

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(_downloadedFiles);
    if (files.contains(file.filename)) {
      return _Preview(file);
    }

    return _Download(file: file);
  }
}

class _Download extends ConsumerWidget {
  const _Download({required this.file});

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(cmsClientProvider);
    return IconButton(
      onPressed: () async {
        if (await client.download(file)) {
          ref
              .read(_downloadedFiles.notifier)
              .update((state) => state.add(file.filename));
        } else {
          logger.w("Error while downloading file");
        }
      },
      icon: const Icon(Icons.download),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview(this.file);

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        throw UnimplementedError();
      },
      icon: const Icon(Icons.file_open),
    );
  }
}
