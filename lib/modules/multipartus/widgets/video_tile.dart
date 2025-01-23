import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/modules/multipartus/widgets/thumbnail.dart';
import 'package:lex/utils/misc.dart';
import 'package:lex/widgets/auto_tooltip_text.dart';

class VideoTile extends StatefulWidget {
  const VideoTile({
    super.key,
    required this.onPressed,
    required this.video,
  });

  final LectureVideo video;
  final void Function() onPressed;

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: widget.onPressed,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Thumbnail(
            ttid: widget.video.ttid.toString(),
          ),
          _Title(video: widget.video),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.video,
  });

  final LectureVideo video;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  video.lectureNo.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoTooltipText(
                      text: video.title,
                      tooltipText: video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      formatDate(video.createdAt),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.ttid,
  });

  final String ttid;

  Widget _buildChild(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return VideoThumbnail(
          ttid: ttid,
          fit: BoxFit.cover,
          shouldFadeIn: true,
          showWatchProgress: true,
          width: constraints.maxWidth,
          progressBarHeight: 3,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: ttid,
              createRectTween: (begin, end) =>
                  CurvedRectTween(begin: begin!, end: end!),
              flightShuttleBuilder: (
                flightContext,
                animation,
                flightDirection,
                fromHeroContext,
                toHeroContext,
              ) =>
                  // animate only in the push direction
                  flightDirection == HeroFlightDirection.push
                      ? toHeroContext.widget
                      : SizedBox(),
              placeholderBuilder: (context, heroSize, child) => child,
              child: _buildChild(context),
            ),
          ),
        ],
      ),
    );
  }
}
