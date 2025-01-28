import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:signals/signals_flutter.dart';

class _FilterItemWidget extends StatelessWidget {
  const _FilterItemWidget({
    required this.isSelected,
    required this.isDisabled,
    required this.text,
    required this.onSelected,
    required this.alignment,
  }) : assert(
          !(isSelected && isDisabled),
          "can't be selected and disabled at the same time",
        );

  final bool isSelected, isDisabled;
  final void Function() onSelected;
  final AlignmentGeometry alignment;
  final String text;

  Color _getForegroundColor(BuildContext context) =>
      switch ((isSelected, isDisabled)) {
        (true, _) => Theme.of(context).colorScheme.surfaceContainerHigh,
        (false, false) => Theme.of(context).colorScheme.onSurface,
        (false, true) => Theme.of(context).disabledColor,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onSelected,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Text(
            text,
            style: TextStyle(
              color: _getForegroundColor(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class FilterDropdown<V> extends StatefulWidget {
  const FilterDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    required this.selected,
  });

  final List<ProfessorSession> items;
  final ProfessorSession selected;
  final void Function(ProfessorSession selected) onSelected;

  @override
  State<FilterDropdown<V>> createState() => _FilterDropdownState<V>();
}

class _FilterDropdownState<V> extends State<FilterDropdown<V>>
    with SignalsMixin {
  final _layerLink = LayerLink();
  final _overlayController = OverlayPortalController();

  void _onPressed() {
    _overlayController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 16);

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => CompositedTransformFollower(
        showWhenUnlinked: false,
        link: _layerLink,
        followerAnchor: Alignment.topCenter,
        targetAnchor: Alignment.bottomCenter,
        offset: Offset(0, 18),
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: TapRegion(
            onTapOutside: (event) => _overlayController.hide(),
            consumeOutsideTaps: true,
            child: SizedBox(
              width: 500,
              child: _FilterPopupOther(
                items: widget.items,
                onSelected: (selected) {
                  _overlayController.hide();
                  widget.onSelected(selected);
                },
              ),
            ),
          ),
        ),
      ),
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: InkWell(
            onTap: _onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      widget.selected.professor,
                      style: style,
                    ),
                  ),
                  // align with the divider
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: SizedBox(
                      height: 36,
                      child: VerticalDivider(
                        color: Theme.of(context).colorScheme.outline,
                        width: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _sessionToText(widget.selected.session),
                      style: style,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterPopupOther extends StatelessWidget {
  const _FilterPopupOther({required this.items, required this.onSelected});

  final List<ProfessorSession> items;
  final void Function(ProfessorSession selected) onSelected;

  Widget _buildItem(String item1, String item2, [TextStyle? style]) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Expanded(child: Text(item1, style: style)),
            const SizedBox(width: 40),
            Expanded(
              child: Text(item2, style: style),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(6),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 200),
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelected(items[index]),
                  child: _buildItem(
                    items[index].professor,
                    _sessionToText(items[index].session),
                  ),
                ),
              );
            },
            itemCount: items.length,
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          duration: 140.ms,
          curve: Curves.easeOutCubic,
          begin: -0.04,
          end: 0,
        )
        .fadeIn(duration: 160.ms);
  }
}

class _FilterPopup extends StatefulWidget {
  const _FilterPopup({required this.items, required this.onSelected});

  final List<ProfessorSession> items;
  final void Function(ProfessorSession selected) onSelected;
  @override
  State<_FilterPopup> createState() => _FilterPopupState();
}

class _FilterPopupState extends State<_FilterPopup> {
  late final _professors = widget.items.map((e) => e.professor).toSet();
  late final _sessions = widget.items.map((e) => e.session).toSet();

  late final _selectedProf = signal<String?>(null);
  late final _selectedSession = signal<ImpartusSession?>(null);

  late final _filteredItems = computed(
    () => widget.items
        .where((e) => _selectedProf() == null || e.professor == _selectedProf())
        .where(
          (e) => _selectedSession() == null || e.session == _selectedSession(),
        )
        .toList(),
  );

  late final _filteredProfs =
      computed(() => _filteredItems().map((e) => e.professor).toSet());
  late final _filteredSessions =
      computed(() => _filteredItems().map((e) => e.session).toSet());

  void _tryUpdate() {
    final prof = _selectedProf();
    final session = _selectedSession();

    if (prof != null && session != null) {
      widget.onSelected((professor: prof, session: session));
    }
  }

  void _onSessionSelect(ImpartusSession session) {
    _selectedSession.value = session == _selectedSession() ? null : session;
    _tryUpdate();
  }

  void _onProfSelect(String prof) {
    _selectedProf.value = prof == _selectedProf() ? null : prof;
    _tryUpdate();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.items.isNotEmpty, "cannot have an empty list of items");

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.only(top: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Watch(
                (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "PROFESSOR",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final prof in _professors)
                        _FilterItemWidget(
                          isSelected: prof == _selectedProf(),
                          isDisabled: _selectedSession() != null &&
                              !_filteredProfs().contains(prof),
                          onSelected: () => _onProfSelect(prof),
                          alignment: AlignmentDirectional.centerStart,
                          text: prof,
                        ),
                    ],
                  );
                },
              ),
            ),
            // VerticalDivider(
            //   color: Theme.of(context).colorScheme.outline,
            //   width: 1,
            //   endIndent: 12,
            // ),
            Expanded(
              child: Watch(
                (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "SESSION",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final session in _sessions)
                        _FilterItemWidget(
                          isSelected: session == _selectedSession(),
                          isDisabled: _selectedProf() != null &&
                              !_filteredSessions().contains(session),
                          onSelected: () => _onSessionSelect(session),
                          alignment: AlignmentDirectional.centerStart,
                          text: _sessionToText(session),
                        ),
                    ],
                  );
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
    _selectedProf.dispose();
    _selectedSession.dispose();
    _filteredItems.dispose();
    _filteredProfs.dispose();
    _filteredSessions.dispose();

    super.dispose();
  }
}

String _sessionToText(ImpartusSession session) => session.isUnknown
    ? "Unknown session"
    : "${session.year!}-${session.year! + 1}, Sem ${session.sem}";

class Filter<V> {
  final String name;
  final bool Function(V item) evaluate;

  Filter(this.name, this.evaluate);
}
