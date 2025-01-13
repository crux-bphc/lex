import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/utils/image.dart';
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowHoverHighlight: (value) {
        setState(() => _isHovered = value);
      },
      child: GridButton(
        onPressed: widget.onPressed,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Thumbnail(
              ttid: widget.video.ttid.toString(),
              showPlayButton: _isHovered,
            ),
            _Title(video: widget.video),
          ],
        ),
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
    this.showPlayButton = false,
  });

  final String ttid;
  final bool showPlayButton;

  @override
  Widget build(BuildContext context) {
    final child = Image.network(
      getThumbnailUrl(ttid),
      fit: BoxFit.cover,
      frameBuilder: fadeInImageFrameBuilder(),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          LucideIcons.image,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
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
              child: child,
            ),
          ),
          Container(
            color: Colors.black38,
            child: Center(
              child: Icon(
                LucideIcons.circle_play,
                size: 50,
                weight: 0.1,
              ),
            ),
          )
              .animate(target: showPlayButton ? 1 : 0)
              .fade(duration: Durations.short2),
        ],
      ),
    );
  }
}
