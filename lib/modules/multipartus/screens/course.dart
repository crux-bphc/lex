import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/models/subject.dart';

class MultipartusCoursePage extends StatelessWidget {
  const MultipartusCoursePage({super.key, required this.subjectId});

  final SubjectId subjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.pop(),
          child: Text("You are looking at ${subjectId.routeId}"),
        ),
      ),
    );
  }
}
