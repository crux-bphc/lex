import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:signals/signals_flutter.dart';

class SectionSessionFilter<V> extends StatefulWidget {
  const SectionSessionFilter({
    super.key,
    required this.items,
    required this.onSelected,
    required this.selected,
    this.width = 540,
  });

  final List<SectionSession> items;
  final SectionSession selected;
  final void Function(SectionSession selected) onSelected;
  final double width;

  @override
  State<SectionSessionFilter<V>> createState() =>
      _SectionSessionFilterState<V>();
}

class _SectionSessionFilterState<V> extends State<SectionSessionFilter<V>>
    with SignalsMixin {
  final _layerLink = LayerLink();
  final _overlayController = OverlayPortalController();

  void _onPressed() {
    _overlayController.toggle();
  }

  void _onPopupSelected(SectionSession selected) {
    widget.onSelected(selected);
    _overlayController.hide();
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
              child: _FilterPopup(
                items: widget.items,
                onSelected: _onPopupSelected,
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
              first: widget.selected.lectureSection,
              second: widget.selected.professor,
              third: _sessionToText(widget.selected.session),
              middleWidget: (context) => CompositedTransformTarget(
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
    required this.middleWidget,
    required this.padding,
    this.style,
  });

  final String first, second, third;
  final WidgetBuilder middleWidget;
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
          Builder(builder: middleWidget),
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

class _FilterPopup extends StatelessWidget {
  const _FilterPopup({required this.items, required this.onSelected});

  final List<SectionSession> items;
  final void Function(SectionSession selected) onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      clipBehavior: Clip.hardEdge,
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
                  first: items[index].lectureSection,
                  second: items[index].professor,
                  third: _sessionToText(items[index].session),
                  middleWidget: (context) => SizedBox(width: 40),
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
          begin: -0.08,
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

String _sessionToText(ImpartusTimeSession session) => session.isUnknown
    ? "Unknown session"
    : "${session.year!}-${session.year! + 1}, Sem ${session.sem}";
