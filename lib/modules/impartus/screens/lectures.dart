import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImpartusLecturesPage extends StatelessWidget {
  const ImpartusLecturesPage({
    super.key,
    required this.subjectId,
    required this.sessionId,
  });

  final String subjectId;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: BackButton(
            onPressed: () {
              context.pop();
            },
          ),
          title: const Text("Subject Name"),
        ),
      ],
    );
  }
}
