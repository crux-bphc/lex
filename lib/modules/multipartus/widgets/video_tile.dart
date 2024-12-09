import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/screens/video.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/widgets/auto_tooltip_text.dart';

final _dateFormat = DateFormat.yMMMd().add_jm();

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
              ttid: widget.video.video.ttid.toString(),
              showPlayButton: _isHovered,
            ),
            _Title(video: widget.video.video),
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

  final ImpartusVideo video;

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
                      text: video.topic,
                      tooltipText: video.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      _dateFormat.format(video.createdAt),
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

const _heroFadeCurve = Curves.easeOutQuint;

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
      "https://a.impartus.com/download1/embedded/thumbnails/$ttid.jpg",
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
              ) {
                return flightDirection == HeroFlightDirection.push
                    ? Container(
                        color: Colors.black,
                        child: AnimatedBuilder(
                          animation: CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastLinearToSlowEaseIn,
                          ),
                          builder: (context, child) => Opacity(
                            opacity:
                                _heroFadeCurve.transform(1 - animation.value),
                            child: child,
                          ),
                          child: child,
                        ),
                      )
                    : FadeTransition(
                        opacity: animation.drive(Tween(begin: 1, end: 0)),
                        child: child,
                      );
              },
              child: child,
            ),
          ),
          AnimatedOpacity(
            opacity: showPlayButton ? 1 : 0,
            duration: Duration(milliseconds: 100),
            child: Container(
              color: Colors.black38,
              child: Center(
                child: Icon(
                  LucideIcons.circle_play,
                  size: 50,
                  weight: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
