import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_tile.dart';
import 'package:signals/signals_flutter.dart';

class FilterableVideoGrid extends StatefulWidget {
  const FilterableVideoGrid({
    super.key,
    required this.professorSessionMap,
    required this.videos,
    required this.onPressed,
  });

  final Map<String, Set<ImpartusSession>> professorSessionMap;
  final List<LectureVideo> videos;
  final void Function(LectureVideo video) onPressed;

  @override
  State<FilterableVideoGrid> createState() => _FilterableVideoGridState();
}

class _FilterableVideoGridState extends State<FilterableVideoGrid> {
  late final professors = widget.professorSessionMap.keys.toList();

  late final professor = signal<String?>(
    professors.first,
    autoDispose: true,
    debugLabel: 'ui | professor',
  );
  late final sessions = computed(
    () => widget.professorSessionMap[professor()]?.toList() ?? [],
    autoDispose: true,
    debugLabel: 'ui | sessions',
  );

  late final session = signal<ImpartusSession?>(
    sessions().first,
    autoDispose: true,
    debugLabel: 'ui | session',
  );

  late final videos = computed(
    () {
      final p = professor();
      final s = session();
      return widget.videos
          .where((v) => v.session == s && v.section.professor == p)
          .toList();
    },
    autoDispose: true,
    debugLabel: 'ui | videos',
  );

  late final Function() effectDispose;

  @override
  void initState() {
    super.initState();

    effectDispose = effect(
      () {
        session.value = sessions().first;
      },
      debugLabel: 'ui | session effect',
    );
  }

  @override
  void dispose() {
    effectDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          pinned: true,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          title: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownMenu(
                  dropdownMenuEntries: [
                    for (final prof in professors)
                      DropdownMenuEntry(
                        value: prof,
                        label: prof,
                      ),
                  ],
                  hintText: "PROFESSOR",
                  onSelected: (value) {
                    professor.value = value;
                  },
                  initialSelection: professors.first,
                ),
                const SizedBox(width: 12),
                Watch(
                  (context) => DropdownMenu(
                    dropdownMenuEntries: [
                      for (final session in sessions())
                        DropdownMenuEntry(
                          label:
                              "${session.year}-${session.year + 1}, Sem ${session.sem}",
                          value: session,
                        ),
                    ],
                    hintText: "SESSION",
                    onSelected: (value) {
                      session.value = value;
                    },
                    initialSelection: sessions().first,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 12, bottom: 30),
          sliver: Watch(
            (context) => _ImpartusVideoGrid(
              videos: videos(),
              onPressed: widget.onPressed,
            ),
          ),
        ),
      ],
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
        return VideoTile(
          video: videos[i],
          onPressed: () => onPressed(videos[i]),
        );
      },
      itemCount: videos.length,
    );
  }
}
