import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/modules/multipartus/widgets/subject_tile.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/providers/local_storage/watch_history.dart';
import 'package:lex/utils/image.dart';
import 'package:lex/utils/misc.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:lex/widgets/floating_sidebar.dart';
import 'package:signals/signals_flutter.dart';

const _loadingWidget = Center(child: DelayedProgressIndicator());

class MultipartusHomePage extends StatefulWidget {
  const MultipartusHomePage({super.key});

  @override
  State<MultipartusHomePage> createState() => _MultipartusHomePageState();
}

class _MultipartusHomePageState extends State<MultipartusHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 30, top: 30, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultipartusTitle(),
            SizedBox(height: 20),
            Expanded(child: _Main()),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    debugPrint("deactivated");
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint("disposed");
    super.dispose();
  }
}

class _Main extends StatelessWidget {
  const _Main();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _Subjects()),
        const SizedBox(width: 5),
        _ContinueWatching(),
      ],
    );
  }
}

class _Subjects extends StatefulWidget {
  const _Subjects();

  @override
  State<_Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<_Subjects> with SignalsMixin {
  final ScrollController scrollController = ScrollController();

  final _searchText = signal('');

  late final isSearchMode = createComputed(() => _searchText().isEmpty);

  late final _debouncedTextUpdater = debouncer<String>(
    (t) => _searchText.value = t,
    duration: Durations.medium2,
  );

  void _handleSubjectPressed(Subject subject) {
    context.go(
      '/multipartus/courses/${subject.departmentUrl}/${subject.code}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 25),
          child: _SearchBar(
            onUpdate: (t) => _debouncedTextUpdater(t, now: t.isEmpty),
            onSubmit: (t) => _debouncedTextUpdater(t, now: true),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Watch(
            (context) {
              if (isSearchMode()) {
                return Watch((context) {
                  final subjects =
                      GetIt.instance<MultipartusService>().pinnedSubjects();
                  return subjects.map(
                    data: (data) => _SubjectGrid(
                      subjects: data.values.toList(),
                      onPressed: _handleSubjectPressed,
                    ),
                    error: (e, _) => Text("Error: $e"),
                    loading: () => _loadingWidget,
                  );
                });
              } else {
                return FutureBuilder(
                  future: GetIt.instance<MultipartusService>()
                      .searchSubjects(_searchText()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _loadingWidget;
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }

                    return _SubjectGrid(
                      subjects: snapshot.data as List<Subject>,
                      onPressed: _handleSubjectPressed,
                      emptyText: "No subjects found",
                    )
                        .animate()
                        .slideY(
                          duration: 200.ms,
                          curve: Curves.easeOutCubic,
                          begin: 0.01,
                          end: 0,
                        )
                        .fadeIn(
                          duration: 180.ms,
                        );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchText.dispose();
    super.dispose();
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.onUpdate, required this.onSubmit});

  final void Function(String text) onUpdate, onSubmit;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      autoFocus: true,
      hintText: "Search for any course",
      onChanged: (t) => widget.onUpdate(t.trim()),
      onSubmitted: (t) => widget.onSubmit(t.trim()),
      focusNode: _focusNode,
      trailing: [
        IconButton(
          icon: Icon(
            LucideIcons.search,
            size: 20,
          ),
          onPressed: () => widget.onSubmit(_controller.text),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SubjectGrid extends StatefulWidget {
  const _SubjectGrid({
    required this.subjects,
    required this.onPressed,
    this.emptyText = "No subjects to show",
  });

  final List<Subject> subjects;
  final void Function(Subject subject) onPressed;
  final String emptyText;

  @override
  State<_SubjectGrid> createState() => _SubjectGridState();
}

class _SubjectGridState extends State<_SubjectGrid> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
      return Center(child: Text(widget.emptyText));
    }

    return Scrollbar(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.only(right: 25),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              mainAxisExtent: 208,
              maxCrossAxisExtent: 340,
            ),
            physics: BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast,
            ),
            itemBuilder: (context, i) => SubjectTile(
              onPressed: () => widget.onPressed(widget.subjects[i]),
              subject: widget.subjects[i],
            ),
            itemCount: widget.subjects.length,
          ),
        ),
      ),
    );
  }
}

class _ContinueWatching extends StatefulWidget {
  @override
  State<_ContinueWatching> createState() => _ContinueWatchingState();
}

class _ContinueWatchingState extends State<_ContinueWatching> {
  List<(String, WatchHistoryItem)> _getItems() {
    return GetIt.instance<LocalStorage>().watchHistory.readAll();
  }

  late List<(String, WatchHistoryItem)> items = _getItems();

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Container();

    return Container(
      width: 340,
      padding: EdgeInsets.only(right: 30),
      child: FloatingSidebar(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "CONTINUE WATCHING",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // change this horrible shit
                IconButton(
                  onPressed: () => setState(() => items = _getItems()),
                  icon: Icon(LucideIcons.refresh_cw),
                  iconSize: 20,
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final code = items[index].$2.code;
                  final departmentUrl = items[index].$2.departmentUrl;
                  final department = departmentUrl.replaceAll(',', '/');
                  final ttid = items[index].$1;

                  return RawMaterialButton(
                    onPressed: () {
                      context.go(
                        '/multipartus/courses/$departmentUrl/$code/watch/$ttid',
                      );
                    },
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: FutureBuilder(
                      future: GetIt.instance<MultipartusService>()
                          .fetchLectureVideo(
                        department: department,
                        code: code,
                        ttid: ttid.toString(),
                      ),
                      builder: (context, snapshot) {
                        final title = snapshot.data?.title;
                        final isLoading =
                            snapshot.connectionState != ConnectionState.done;

                        return Row(
                          children: [
                            _MiniVideoThumbnail(
                              ttid: ttid,
                              positionFraction: items[index].$2.fraction,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLoading ? "" : (title ?? "Unknown title"),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    "$department $code",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
                itemCount: items.length,
              ).animate().fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniVideoThumbnail extends StatelessWidget {
  const _MiniVideoThumbnail({
    required this.positionFraction,
    this.ttid,
  });

  final String? ttid;
  final double positionFraction;
  final double height = 46;

  @override
  Widget build(BuildContext context) {
    final width = height * 16 / 9;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.black45,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (ttid != null)
            Image.network(
              getThumbnailUrl(ttid!),
              filterQuality: FilterQuality.none,
            ),
          // Icon(LucideIcons.circle_play),
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Container(
              height: 2,
              width: width * positionFraction.clamp(0.16, 1),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
