import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:lex/modules/multipartus/models/impartus_video.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/modules/multipartus/widgets/video_thumbnail.dart';
import 'package:lex/utils/misc.dart';
import 'package:lex/widgets/auto_tooltip_text.dart';

class VideoButton extends StatefulWidget {
  const VideoButton({
    super.key,
    required this.onPressed,
    required this.video,
    this.titleFontSize = 18,
    this.lectureNoFontSize = 30,
    this.dateFontSize = 12,
    required = 16,
    this.gap = 16,
    this.isCurrentlyWatching = false,
  });

  final ImpartusVideo video;
  final void Function() onPressed;
  final double titleFontSize, lectureNoFontSize, dateFontSize, gap;
  final bool isCurrentlyWatching;

  @override
  State<VideoButton> createState() => _VideoButtonState();
}

class _VideoButtonState extends State<VideoButton> {
  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: widget.onPressed,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                _Thumbnail(
                  ttid: widget.video.ttid.toString(),
                ),
                if (widget.isCurrentlyWatching)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.video,
                            color: Theme.of(context).colorScheme.surface,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "CURRENTLY WATCHING",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _Title(
              video: widget.video,
              titleFontSize: widget.titleFontSize,
              dateFontSize: widget.dateFontSize,
              lectureNoFontSize: widget.lectureNoFontSize,
              gap: widget.gap,
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.video,
    required this.titleFontSize,
    required this.lectureNoFontSize,
    required this.dateFontSize,
    required this.gap,
  });

  final ImpartusVideo video;
  final double titleFontSize, lectureNoFontSize, dateFontSize, gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: gap),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                video.lectureNo.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: lectureNoFontSize,
                ),
              ),
            ),
            SizedBox(width: gap),
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
                      fontSize: titleFontSize,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    formatDate(video.createdAt),
                    style: TextStyle(
                      fontSize: dateFontSize,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.ttid});

  final String ttid;

  @override
  Widget build(BuildContext context) {
    // Hero(
    //   tag: ttid,
    //   createRectTween: (begin, end) =>
    //       CurvedRectTween(begin: begin!, end: end!),
    //   flightShuttleBuilder: (
    //     flightContext,
    //     animation,
    //     flightDirection,
    //     fromHeroContext,
    //     toHeroContext,
    //   ) =>
    //       // animate only in the push direction
    //       flightDirection == HeroFlightDirection.push
    //           ? toHeroContext.widget
    //           : SizedBox(),
    //   placeholderBuilder: (context, heroSize, child) => child,
    //   child: _buildChild(context),
    // );

    return LayoutBuilder(
      builder: (context, constraints) {
        return VideoThumbnail(
          ttid: ttid,
          fit: BoxFit.cover,
          shouldFadeIn: true,
          showWatchProgress: true,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          progressBarHeight: 3,
        );
      },
    );
  }
}
