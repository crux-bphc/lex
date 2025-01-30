import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:signals/signals_flutter.dart';

class FilterDropdown<V> extends StatefulWidget {
  const FilterDropdown({
    super.key,
    required this.items,
    required this.onSelected,
    required this.selected,
    this.width = 540,
  });

  final List<ProfessorSession> items;
  final ProfessorSession selected;
  final void Function(ProfessorSession selected) onSelected;
  final double width;

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
              width: widget.width,
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
        width: widget.width,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: InkWell(
            onTap: _onPressed,
            child: _Item(
              style: style,
              first: widget.selected.section.section,
              second: widget.selected.professor,
              third: _sessionToText(widget.selected.session),
              middle: (context) => CompositedTransformTarget(
                link: _layerLink,
                child: SizedBox(
                  height: 36,
                  child: VerticalDivider(
                    color: Theme.of(context).colorScheme.outline,
                    width: 40,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.first,
    required this.second,
    required this.third,
    required this.middle,
    required this.padding,
    this.style,
  });

  final String first, second, third;
  final WidgetBuilder middle;
  final TextStyle? style;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: _SectionText(
                    first,
                    style: (style ?? TextStyle()).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(second, style: style),
                ),
              ],
            ),
          ),
          // align with the divider
          Builder(builder: middle),
          Expanded(
            child: Text(
              third,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPopupOther extends StatelessWidget {
  const _FilterPopupOther({required this.items, required this.onSelected});

  final List<ProfessorSession> items;
  final void Function(ProfessorSession selected) onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(6),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(items[index]),
                child: _Item(
                  first: items[index].section.section,
                  second: items[index].professor,
                  third: _sessionToText(items[index].session),
                  middle: (context) => SizedBox(width: 40),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
            );
          },
          itemCount: items.length,
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

class _SectionText extends StatelessWidget {
  const _SectionText(
    this.text, {
    required this.style,
  });

  final String text;
  final TextStyle style;

  Color _color(BuildContext context) =>
      switch (text.toUpperCase().substring(0, 1)) {
        "L" => Theme.of(context).colorScheme.secondary,
        "T" => Theme.of(context).colorScheme.tertiary,
        _ => Theme.of(context).colorScheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(color: _color(context)),
    );
  }
}

String _sessionToText(ImpartusSession session) => session.isUnknown
    ? "Unknown session"
    : "${session.year!}-${session.year! + 1}, Sem ${session.sem}";
