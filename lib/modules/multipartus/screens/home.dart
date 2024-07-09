import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:lex/modules/multipartus/widgets/login_gate.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';

class MultipartusHomePage extends StatelessWidget {
  const MultipartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MultipartusLoginGate(
        child: Padding(
          padding: EdgeInsets.all(40),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              flex: 5,
              child: SearchBar(
                leading: Icon(
                  LucideIcons.search,
                  size: 20,
                ),
                hintText: "Search for any course",
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("View All Courses"),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.31,
            children: [],
          ),
        ),
      ],
    );
  }
}
