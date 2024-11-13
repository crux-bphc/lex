import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/widgets/auto_tooltip_text.dart';

final _dateFormat = DateFormat.yMMMd().add_jm();

class VideoTile extends StatelessWidget {
  const VideoTile({
    super.key,
    required this.onPressed,
    required this.video,
  });

  final LectureVideo video;

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: Image.network(
              "https://a.impartus.com/download1/embedded/thumbnails/${video.video.ttid}.jpg",
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                // fade in image
                if (wasSynchronouslyLoaded) return child;
                return child
                    .animate(target: frame != null ? 1 : 0)
                    .fadeIn(duration: 400.ms);
              },
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  LucideIcons.image,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoTooltipText(
                    text:
                        "Lecture ${video.video.lectureNo}: ${video.video.topic}",
                    tooltipText: video.video.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    _dateFormat.format(video.video.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
