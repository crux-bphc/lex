import 'package:flutter/material.dart';

class ImpartusHomePage extends StatelessWidget {
  const ImpartusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Impartus"),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.download),
            )
          ],
        ),
      ],
    );
  }
}
