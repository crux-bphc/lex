import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/settings/widgets/tile.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:signals/signals_flutter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: BackButton(
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [
              // _CMSSettings(),
              _AccountSettings(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountSettings extends StatelessWidget {
  const _AccountSettings();

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.instance<AuthProvider>();

    return SettingsTile(
      title: "Account",
      children: [
        Watch(
          (context) => OutlinedButton.icon(
            onPressed: auth.isLoggedIn() ? auth.logout : null,
            icon: const Icon(LucideIcons.log_out),
            label: const Text("Logout"),
          ),
        ),
      ],
    );
  }
}
