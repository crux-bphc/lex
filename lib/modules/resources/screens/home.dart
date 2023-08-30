import 'package:flutter/material.dart';
import 'package:lex/modules/resources/widgets/card.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ResourcesHomePage extends StatelessWidget {
  const ResourcesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Extra Resources"),
        ),
        const Expanded(child: _Content()),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  Future<void> _launchUrl(url) async {
    if (!await launchUrlString(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      children: [
        ResourceCard(
          title: "CMS Scraper",
          children: [
            const Text(
              "Collection of all files and discussions from the Moodle based Course Management System for BPHC from previous years compiled in a drive.",
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                TextButton(
                  onPressed: () {
                    _launchUrl("https://tinyurl.com/cms-backups");
                  },
                  child: const Text("Drive Link"),
                ),
                TextButton(
                  onPressed: () {
                    _launchUrl("https://github.com/crux-bphc/CMS-Scraper");
                  },
                  child: const Text("Scraper (on GitHub)"),
                ),
              ],
            ),
          ],
        ),
        ResourceCard(
          title: "Handouts for You",
          children: [
            const Text("A website to filter out handouts"),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _launchUrl("https://handoutsforyou.vercel.app/");
              },
              child: const Text("Website Link"),
            ),
          ],
        ),
      ],
    );
  }
}
