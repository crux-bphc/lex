import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/backend.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MultipartusVideoPage extends StatelessWidget {
  const MultipartusVideoPage({super.key, required this.ttid});

  final String ttid;

  @override
  Widget build(BuildContext context) {
    final client = GetIt.instance<LexBackend>().client!;
    final accessToken = Uri.encodeQueryComponent(
      GetIt.instance<AuthProvider>().currentUser.value!.accessToken!,
    );
    final baseUrl = client.options.baseUrl;

    return _Player(
      link: '${baseUrl}impartus/video/$ttid/m3u8?token=$accessToken',
      headers: const {},
    );
  }
}

class _Player extends StatefulWidget {
  const _Player({required this.link, required this.headers});

  final String link;
  final Map<String, String> headers;

  @override
  State<_Player> createState() => __PlayerState();
}

class __PlayerState extends State<_Player> {
  late final player = Player(
    configuration: PlayerConfiguration(
      ready: () {
        debugPrint('Player ready');
      },
    ),
  );

  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    _setup();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _setup() async {
    await player.open(Media(widget.link));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Video(controller: controller),
    );
  }
}
