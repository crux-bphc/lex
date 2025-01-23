import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/local_storage/local_storage.dart';

const _thumbnailBase = String.fromEnvironment("THUMBNAIL_URL");

String getThumbnailUrl(String ttid) {
  return "$_thumbnailBase/$ttid.jpg";
}

class VideoThumbnail extends StatelessWidget {
  const VideoThumbnail({
    super.key,
    required this.ttid,
    this.showWatchProgress = false,
    this.shouldFadeIn = false,
    this.errorBuilder,
    this.fit,
    this.height,
    this.width,
    this.fadeDuration = Durations.short4,
  }) : assert(
          !showWatchProgress || width != null,
          "width must be provided when showWatchProgress is true",
        );

  final String ttid;
  final bool shouldFadeIn;
  final bool showWatchProgress;
  final Duration fadeDuration;

  final BoxFit? fit;

  final double? height, width;

  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  Widget _buildWithProgress(BuildContext context, Widget child) {
    final positionFraction =
        GetIt.instance<LocalStorage>().watchHistory.read(ttid)?.fraction;
    if (positionFraction == null) {
      return child;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Container(
            height: 2,
            width: width! * positionFraction.clamp(0.16, 1),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildChild() {
    final errorBuilder = this.errorBuilder ??
        (context, error, stackTrace) => Center(
              child: Icon(
                LucideIcons.image,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            );

    if (shouldFadeIn) {
      return FadeInImage.memoryNetwork(
        image: getThumbnailUrl(ttid),
        fadeOutDuration: Durations.short1,
        fadeInDuration: fadeDuration,
        placeholder: kTransparentImage,
        imageErrorBuilder: errorBuilder,
        height: height,
        width: width,
        fit: fit,
      );
    }

    return Image.network(
      getThumbnailUrl(ttid),
      errorBuilder: errorBuilder,
      fit: fit,
      height: height,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();

    if (showWatchProgress) {
      return _buildWithProgress(context, child);
    }

    return child;
  }
}

// from package:transparent_image

final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
