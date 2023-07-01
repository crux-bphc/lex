import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/modules/settings/widgets/tile.dart';
import 'package:ghotpromax/providers/cms.dart';
import 'package:ghotpromax/providers/impartus.dart';
import 'package:go_router/go_router.dart';

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
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [_ImpartusSettings(), _CMSSettings()],
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
  const _CMSSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(cmsTokenProvider);
    return SettingsTile(
      title: "CMS",
      children: [
        TextFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.token),
            labelText: "Web service token",
          ),
          initialValue: token,
          onFieldSubmitted: (value) {
            ref.read(cmsTokenProvider.notifier).state = value;
          },
        )
      ],
    );
  }
}
