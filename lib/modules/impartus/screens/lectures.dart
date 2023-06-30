import 'package:flutter/material.dart';

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
          title: const Text("Subject Name"),
        ),
      ],
    );
  }
}
