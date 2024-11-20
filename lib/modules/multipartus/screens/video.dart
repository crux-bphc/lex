import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/backend.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MultipartusVideoPage extends StatelessWidget {
  const MultipartusVideoPage({
    super.key,
    required this.ttid,
    required this.subjectCode,
    required this.departmentUrl,
  });

  final String subjectCode, departmentUrl, ttid;

  @override
  Widget build(BuildContext context) {
    final client = GetIt.instance<LexBackend>().dioClient!;
    final accessToken = Uri.encodeQueryComponent(
      GetIt.instance<AuthProvider>().currentUser.value!.accessToken!,
    );
    final baseUrl = client.options.baseUrl;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Player(
                      link:
                          '${baseUrl}impartus/video/$ttid/m3u8?token=$accessToken',
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(top: 20, bottom: 14),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        "UP NEXT IN COURSE",
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    "SLIDES",
                    style: Theme.of(context)
                        .dialogTheme
                        .titleTextStyle!
                        .copyWith(letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Player extends StatefulWidget {
  const _Player({required this.link});

  final String link;

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
    super.dispose();

    player.dispose();
  }

  @override
  void didUpdateWidget(covariant _Player oldWidget) {
    _setup();

    super.didUpdateWidget(oldWidget);
  }

  void _setup() async {
    await player.open(Media(widget.link));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: AspectRatio(
              aspectRatio: 1280 / 720,
              child: Video(controller: controller),
            ),
          );
        },
      ),
    );
  }
}
