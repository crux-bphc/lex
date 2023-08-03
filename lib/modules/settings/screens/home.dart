import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/settings/widgets/tile.dart';
import 'package:ghotpromax/providers/cms.dart';
import 'package:ghotpromax/providers/impartus.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: BackButton(
          onPressed: () {
            context.go('/cms');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [_ImpartusSettings(), _CMSSettings()],
          ),
        ),
      ),
    );
  }
}

class _ImpartusSettings extends ConsumerWidget {
  const _ImpartusSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(impartusSettingsProvider);
    final settingsNotifier = ref.watch(impartusSettingsProvider.notifier);
    return SettingsTile(
      title: "Impartus",
      children: [
        TextFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email),
            labelText: "E-Mail",
            hintText: "f20XXXXXX@hyderabad.bits-pilani.ac.in",
          ),
          initialValue: settings.email,
          onFieldSubmitted: (value) {
            settingsNotifier.setEmail(value);
          },
        ),
        TextFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.password),
            labelText: "Password",
          ),
          initialValue: settings.password,
          onFieldSubmitted: (value) {
            settingsNotifier.setPassword(value);
          },
        ),
      ],
    );
  }
}

class _CMSSettings extends ConsumerWidget {
  const _CMSSettings();

  Future<void> _showTokenHelpDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "1. Login to the official CMS using your web browser",
                ),
                const Text("2. Go Account > Preferences > Security Keys"),
                TextButton(
                  onPressed: () => launchUrlString(
                    "https://cms.bits-hyderabad.ac.in/user/managetoken.php",
                  ),
                  child: const Text("Manage your Security Tokens"),
                ),
                const Text(
                  "3. Click on the 'Reset' button on the 'Moodle mobile web service' key",
                ),
                const Text(
                  "4. Copy and paste the new 'Moodle mobile web service' key over here.",
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(cmsTokenProvider);
    return SettingsTile(
      title: "CMS",
      children: [
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.token),
            labelText: "Web service token",
            suffixIcon: IconButton(
              onPressed: () => _showTokenHelpDialog(context),
              icon: const Icon(Icons.help),
            ),
          ),
          initialValue: token,
          onFieldSubmitted: (value) {
            ref.read(cmsTokenProvider.notifier).state = value;
          },
        ),
      ],
    );
  }
}
