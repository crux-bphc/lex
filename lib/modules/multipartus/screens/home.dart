import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/modules/multipartus/widgets/subject_tile.dart';
import 'package:lex/utils/misc.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:signals/signals_flutter.dart';

const _loadingWidget = Center(child: DelayedProgressIndicator());

class MultipartusHomePage extends StatelessWidget {
  const MultipartusHomePage({super.key});

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
            Expanded(flex: 5, child: _Subjects()),
          ],
        ),
      ),
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
    duration: const Duration(milliseconds: 300),
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
          padding: const EdgeInsets.only(right: 30),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _SearchBar(
                  onUpdate: (t) => _debouncedTextUpdater(t, now: t.isEmpty),
                  onSubmit: (t) => _debouncedTextUpdater(t, now: true),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text("View All Courses"),
              ),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(right: 30),
        //   child: Row(
        //     children: [
        //       const Expanded(
        //         flex: 5,
        //         child: SearchBar(
        //           leading: Icon(
        //             LucideIcons.search,
        //             size: 20,
        //           ),
        //           hintText: "Search for any course",
        //         ),
        //       ),
        //       const Spacer(),
        //       TextButton(
        //         onPressed: () {},
        //         child: const Text("View All Courses"),
        //       ),
        //     ],
        //   ),
        // ),
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
                return Watch(
                  (context) {
                    return FutureBuilder(
                      future: GetIt.instance<MultipartusService>()
                          .searchSubjects(_searchText()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
      return const Center(child: Text("No subjects to show"));
    }

    return Scrollbar(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.only(right: 30),
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
