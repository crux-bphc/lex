import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/widgets/login_gate.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';

class MultipartusHomePage extends StatelessWidget {
  const MultipartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MultipartusLoginGate(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MultipartusTitle(),
              SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _Courses()),
                    SizedBox(width: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Courses extends StatelessWidget {
  const _Courses();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
