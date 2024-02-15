import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class ImpartusLecturePage extends StatelessWidget {
  const ImpartusLecturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: const BackButton(),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _VideoPlayer(),
          ),
        ),
      ],
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  const _VideoPlayer();
  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(
      Media(
        'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.mp4/.m3u8',
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(controller: controller);
  }
}
