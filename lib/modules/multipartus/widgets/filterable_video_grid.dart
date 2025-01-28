import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/video_tile.dart';
import 'package:lex/widgets/bird.dart';
import 'package:lex/widgets/linked_dropdown.dart';
import 'package:signals/signals_flutter.dart';

class FilterableVideoGrid extends StatefulWidget {
  const FilterableVideoGrid({
    super.key,
    required this.videos,
    required this.onPressed,
    required this.professorSessionList,
  });

  final List<LectureVideo> videos;
  final void Function(LectureVideo video) onPressed;
  final List<ProfessorSession> professorSessionList;

  @override
  State<FilterableVideoGrid> createState() => _FilterableVideoGridState();
}

class _FilterableVideoGridState extends State<FilterableVideoGrid> {
  late final _selected = signal(widget.professorSessionList.first);

  late final videos = computed(
    () {
      final p = _selected().professor;
      final s = _selected().session;
      return widget.videos
          .where((v) => v.session == s && v.professor == p)
          .toList();
    },
    autoDispose: true,
    debugLabel: 'ui | videos',
  );

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: Watch(
              (context) {
                return FilterDropdown(
                  items: widget.professorSessionList,
                  onSelected: (s) => _selected.value = s,
                  selected: _selected(),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 12, bottom: 30),
          sliver: Watch(
            (context) {
              final vids = videos();

              if (vids.isEmpty) {
                return SliverFillRemaining(child: ErrorBird());
              }

              return _ImpartusVideoGrid(
                videos: vids,
                onPressed: widget.onPressed,
              );
            },
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
          video: videos[i].video,
          onPressed: () => onPressed(videos[i]),
        );
      },
      itemCount: videos.length,
    );
  }
}
