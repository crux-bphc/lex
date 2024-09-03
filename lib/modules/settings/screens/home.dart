import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/settings/widgets/tile.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/providers/preferences.dart';
import 'package:signals/signals_flutter.dart';
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
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [
              _CMSSettings(),
              _AccountSettings(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CMSSettings extends StatelessWidget {
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = GetIt.instance<Preferences>().cmsToken;

    return SettingsTile(
      title: "CMS",
      children: [
        Watch(
          (context) => TextFormField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.token),
              labelText: "Web service token",
              suffixIcon: IconButton(
                onPressed: () => _showTokenHelpDialog(context),
                icon: const Icon(Icons.help),
              ),
            ),
            initialValue: token.value,
            onFieldSubmitted: (value) {
              token.value = value;
            },
          ),
        ),
      ],
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
