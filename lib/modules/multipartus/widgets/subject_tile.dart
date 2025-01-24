import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';

class SubjectTile extends StatefulWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.onPressed,
    this.eagerUpdate = false,
  });

  final Subject subject;
  final void Function() onPressed;
  final bool eagerUpdate;

  @override
  State<SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<SubjectTile> {
  late bool isPinned;

  @override
  void initState() {
    super.initState();
    isPinned = widget.subject.isPinned;
  }

  void _togglePinnedState() {
    setState(() {
      isPinned = !isPinned;
    });

    if (isPinned) {
      GetIt.instance<MultipartusService>()
          .pinSubject(widget.subject.department, widget.subject.code);
    } else {
      GetIt.instance<MultipartusService>()
          .unpinSubject(widget.subject.department, widget.subject.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: widget.onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                widget.subject.prettyCode.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  if (widget.eagerUpdate) {
                    _togglePinnedState();
                  } else {
                    if (widget.subject.isPinned) {
                      GetIt.instance<MultipartusService>().unpinSubject(
                          widget.subject.department, widget.subject.code);
                    } else {
                      GetIt.instance<MultipartusService>().pinSubject(
                          widget.subject.department, widget.subject.code);
                    }
                  }
                },
                icon: Icon(
                  isPinned ? Icons.favorite : Icons.favorite_border,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft + const Alignment(0, -0.2),
              child: Text(
                widget.subject.name.toUpperCase().trim(),
                style: const TextStyle(
                  fontSize: 26,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
