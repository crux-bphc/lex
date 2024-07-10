import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/models/subject.dart';

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
    return RawMaterialButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF434C5D)),
      ),
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                subject.fullCode.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.favorite,
                size: 22,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft + const Alignment(0, -0.2),
              child: Text(
                subject.name.toUpperCase().trim(),
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
