import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_button.dart';
import 'package:lex/widgets/error_bird.dart';

class VideoGrid extends StatelessWidget {
  const VideoGrid({
    super.key,
    required this.videos,
    required this.onPressed,
  });

  final List<LectureVideo> videos;
  final void Function(LectureVideo video) onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12, bottom: 30),
      sliver: videos.isEmpty
          ? SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorBird(message: "No lectures found"),
            )
          : _ImpartusVideoGrid(
              videos: videos,
              onPressed: onPressed,
            ),
    );
  }
}

class _ImpartusVideoGrid extends StatelessWidget {
  const _ImpartusVideoGrid({required this.videos, required this.onPressed});

  final List<LectureVideo> videos;
  final void Function(LectureVideo) onPressed;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 225,
        maxCrossAxisExtent: 400,
      ),
      itemBuilder: (context, i) {
        return VideoButton(
          video: videos[i].video,
          onPressed: () => onPressed(videos[i]),
        );
      },
      itemCount: videos.length,
    );
  }
}
