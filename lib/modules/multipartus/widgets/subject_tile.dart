import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/models/subject.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/grid_button.dart';
import 'package:signals/signals_flutter.dart';

class SubjectTile extends StatelessWidget {
  const SubjectTile({
    super.key,
    required this.subject,
    required this.onPressed,
  });

  final Subject subject;

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GridButton(
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                subject.prettyCode.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Watch(
                (context) {
                  final service = GetIt.instance<MultipartusService>();
                  final isPinned =
                      service.subjects.value[subject.subjectId]?.isPinned ??
                          false;
                  return IconButton(
                    onPressed: () async {
                      if (isPinned) {
                        await service.unpinSubject(
                          subject.department,
                          subject.code,
                        );
                      } else {
                        await service.pinSubject(
                          subject.department,
                          subject.code,
                        );
                      }
                    },
                    icon: Icon(
                      isPinned ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft + const Alignment(0, -0.2),
              child: Text(
                subject.name.toUpperCase().trim(),
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
