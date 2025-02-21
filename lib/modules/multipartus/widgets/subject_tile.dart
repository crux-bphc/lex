import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:lex/router/scaffold.dart';
import 'package:lex/widgets/are_you_sure_dialog.dart';

class SubjectTile extends StatefulWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.onPressed,
    this.shouldUpdatePinsEagerly = false,
  });

  final Subject subject;
  final void Function() onPressed;

  /// Whether the widget should update the pin state eagerly (without waiting
  /// for the backend to respond to the pin/unpin request).
  final bool shouldUpdatePinsEagerly;

  @override
  State<SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<SubjectTile> {
  late bool isPinned = widget.subject.isPinned;

  void _handleTogglePin() async {
    if (isPinned) {
      final confirmUnpin = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AreYouSureDialog(
            confirmText: "Unpin",
            content: 'Are you sure you want to unpin "${widget.subject.name}"?',
            title: "Unpin subject",
            confirmColor: Theme.of(context).colorScheme.error,
          );
        },
      );

      if (confirmUnpin != true) return;

      GetIt.instance<MultipartusService>()
          .unpinSubject(widget.subject.department, widget.subject.code);
    } else {
      GetIt.instance<MultipartusService>()
          .pinSubject(widget.subject.department, widget.subject.code);
    }

    if (widget.shouldUpdatePinsEagerly) {
      setState(() {
        isPinned = !isPinned;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: widget.onPressed,
      padding: PlatformIsMobile.resolve(
        context,
        mobile: EdgeInsets.fromLTRB(18, 8, 12, 8),
        desktop: EdgeInsets.all(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _PrettyCode(widget.subject.prettyCode.toUpperCase()),
              IconButton(
                onPressed: _handleTogglePin,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          _Title(widget.subject.name.toUpperCase().trim()),
        ],
      ),
    );
  }
}

class _PrettyCode extends StatelessWidget {
  const _PrettyCode(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        code,
        style: TextStyle(
          fontSize: PlatformIsMobile.resolve(context, mobile: 16, desktop: 18),
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft + const Alignment(0, -0.2),
        child: Text(
          title,
          style: TextStyle(
            fontSize:
                PlatformIsMobile.resolve(context, mobile: 22, desktop: 26),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 3,
        ),
      ),
    );
  }
}
