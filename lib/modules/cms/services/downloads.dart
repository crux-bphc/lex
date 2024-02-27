import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:lex/modules/cms/models/course.dart';
import 'package:lex/providers/cms.dart';
import 'package:lex/utils/logger.dart';
import 'package:signals/signals_flutter.dart';

final _downloadedFiles = signal(ISet());

class CMSDownloadFile extends StatelessWidget {
  const CMSDownloadFile({
    super.key,
    required this.file,
  });

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final files = _downloadedFiles.value;
      if (files.contains(file.filename)) {
        return _Preview(file);
      }

      return _Download(file: file);
    });
  }
}

class _Download extends StatelessWidget {
  const _Download({required this.file});

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context) {
    final client = cmsClient();

    return IconButton(
      onPressed: () async {
        if (await client.download(file)) {
          _downloadedFiles.value = _downloadedFiles.value.add(file.filename);
        } else {
          logger.w("Error while downloading file");
        }
      },
      icon: const Icon(Icons.download),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview(this.file);

  final CMSCourseFile file;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        throw UnimplementedError();
      },
      icon: const Icon(Icons.file_open),
    );
  }
}
