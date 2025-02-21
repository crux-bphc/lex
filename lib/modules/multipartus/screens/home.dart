import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/modules/multipartus/widgets/subject_tile.dart';
import 'package:lex/modules/multipartus/widgets/video_thumbnail.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/providers/local_storage/watch_history.dart';
import 'package:lex/utils/misc.dart';
import 'package:lex/widgets/are_you_sure_dialog.dart';
import 'package:lex/widgets/auto_tooltip_text.dart';
import 'package:lex/widgets/error_bird.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:lex/widgets/error_bird_container.dart';
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
            MultipartusTitle(fontSize: 34),
            SizedBox(height: 20),
            Expanded(child: _Main()),
          ],
        ),
      ),
    );
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
  final _textController = TextEditingController();

  late final isSearchMode = createComputed(() => _searchText().isNotEmpty);

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
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.escape): () {
          if (_textController.text.isNotEmpty) {
            _textController.clear();
            _debouncedTextUpdater('', now: true);
          }
        },
      },
      // get focus if the user clicks outside the searchbar
      child: FocusScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: _SearchBar(
                controller: _textController,
                onUpdate: (t) => _debouncedTextUpdater(t, now: t.isEmpty),
                onSubmit: (t) => _debouncedTextUpdater(t, now: true),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Watch(
                (context) {
                  if (isSearchMode()) {
                    return FutureBuilder(
                      future: GetIt.instance<MultipartusService>()
                          .searchSubjects(_searchText()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _loadingWidget;
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return ErrorBirdContainer(
                            "There was a problem while searching",
                          );
                        }

                        return _SubjectGrid(
                          subjects: snapshot.requireData,
                          onPressed: _handleSubjectPressed,
                          emptyText: "No subjects found",
                          eagerUpdate: true,
                        )
                            .animate()
                            .slideY(
                              duration: 200.ms,
                              curve: Curves.easeOutCubic,
                              begin: 0.01,
                              end: 0,
                            )
                            .fadeIn(duration: 180.ms);
                      },
                    );
                  } else {
                    return Watch((context) {
                      final subjects =
                          GetIt.instance<MultipartusService>().pinnedSubjects();
                      return subjects.map(
                        data: (data) => _SubjectGrid(
                          subjects: data.values.toList(),
                          onPressed: _handleSubjectPressed,
                          eagerUpdate: false,
                        ),
                        error: (e, _) {
                          if (e is BackendError) {
                            return ErrorBird(
                              message: e.message,
                            );
                          }

                          return ErrorBird(
                            message:
                                "There was a problem while retrieving your pinned subjects",
                          );
                        },
                        loading: () => _loadingWidget,
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
  const _SearchBar({
    required this.onUpdate,
    required this.onSubmit,
    required this.controller,
  });

  final void Function(String text) onUpdate, onSubmit;
  final TextEditingController controller;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      autoFocus: true,
      hintText: "Search for any course",
      controller: widget.controller,
      onChanged: (t) => widget.onUpdate(t.trim()),
      onSubmitted: (t) => widget.onSubmit(t.trim()),
      focusNode: _focusNode,
      trailing: [
        IconButton(
          icon: Icon(
            widget.controller.text.isNotEmpty
                ? LucideIcons.x
                : LucideIcons.search,
            size: 20,
          ),
          onPressed: () {
            if (widget.controller.text.isNotEmpty) {
              widget.controller.clear();
              widget.onUpdate('');
            } else {
              widget.onSubmit(widget.controller.text);
            }
          },
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}

class _SubjectGrid extends StatefulWidget {
  const _SubjectGrid({
    required this.subjects,
    required this.onPressed,
    this.emptyText = "No subjects to show",
    this.eagerUpdate = false,
  });

  final List<Subject> subjects;
  final void Function(Subject subject) onPressed;
  final String emptyText;
  final bool eagerUpdate;

  @override
  State<_SubjectGrid> createState() => _SubjectGridState();
}

class _SubjectGridState extends State<_SubjectGrid> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
      return ErrorBird(message: widget.emptyText);
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
              shouldUpdatePinsEagerly: widget.eagerUpdate,
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

  void _handleClearHistory() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AreYouSureDialog(
          confirmText: "Clear",
          content: 'Are you sure you want to clear your watch history?',
          title: "Clear watch history",
          confirmColor: Theme.of(context).colorScheme.error,
        );
      },
    );

    if (result == true) {
      GetIt.instance<LocalStorage>().watchHistory.clear();
    }
  }

  Widget _buildList(List<(String, WatchHistoryItem)> items) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          final code = items[index].$2.code;
          final departmentUrl = items[index].$2.departmentUrl;
          final department = departmentUrl.replaceAll(',', '/');
          final ttid = items[index].$1;

          return _WatchHistoryItem(
            ttid: ttid,
            subjectId: SubjectId(department: department, code: code),
            watchFraction: items[index].$2.fraction,
          );
        },
        itemCount: items.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) {
        final items = _getItems();

        if (items.isEmpty) return SizedBox();

        return Container(
          width: 380,
          padding: EdgeInsets.only(right: 30),
          child: FloatingSidebar(
            padding: EdgeInsets.fromLTRB(14, 20, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Spacer(),
                    Text(
                      "CONTINUE WATCHING",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(LucideIcons.trash),
                      onPressed: _handleClearHistory,
                      tooltip: 'Clear history',
                      iconSize: 22,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _buildList(items),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WatchHistoryItem extends StatelessWidget {
  const _WatchHistoryItem({
    required this.subjectId,
    required this.ttid,
    required this.watchFraction,
  });

  final SubjectId subjectId;
  final String ttid;
  final double watchFraction;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        context.go(
          '/multipartus/courses/${subjectId.asUrl}/watch/$ttid',
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
            .fetchImpartusVideo(ttid.toString()),
        builder: (context, snapshot) {
          final title = snapshot.data?.title;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniVideoThumbnail(
                ttid: ttid,
                positionFraction: watchFraction,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: Durations.short4,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: snapshot.hasData || !isLoading
                            ? Colors.transparent
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: AutoTooltipText(
                        text: title ?? (isLoading ? "" : "Unknown title"),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          height: 0,
                        ),
                      )
                          .animate(target: snapshot.hasData ? 1 : 0)
                          .fadeIn(duration: Durations.medium2),
                    ),
                    Text(
                      "${subjectId.department} ${subjectId.code}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniVideoThumbnail extends StatelessWidget {
  const _MiniVideoThumbnail({
    required this.positionFraction,
    required this.ttid,
  });

  final String ttid;
  final double positionFraction;
  final double height = 46;

  @override
  Widget build(BuildContext context) {
    final width = height * 16 / 9;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.black45,
      ),
      clipBehavior: Clip.hardEdge,
      child: VideoThumbnail(
        ttid: ttid,
        showWatchProgress: true,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
