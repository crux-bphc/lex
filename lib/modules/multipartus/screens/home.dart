import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/login_gate.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/modules/multipartus/widgets/subject_tile.dart';
import 'package:signals/signals_flutter.dart';

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
              MultipartusTitle(poweredByCrux: true),
              SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _Subjects()),
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

class _Subjects extends StatelessWidget {
  const _Subjects();

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
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text("View All Courses"),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Expanded(child: _SubjectGrid()),
      ],
    );
  }
}

class _SubjectGrid extends StatelessWidget {
  const _SubjectGrid();

  @override
  Widget build(BuildContext context) {
    final subjects =
        GetIt.instance<MultipartusService>().subjects.watch(context);

    return subjects.map(
      data: (data) => GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 208,
          maxCrossAxisExtent: 340,
        ),
        itemBuilder: (context, i) => SubjectTile(
          onPressed: () {},
          subject: data[i],
        ),
        itemCount: data.length,
      ),
      error: (e) => Text("Error: $e"),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
