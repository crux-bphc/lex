import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/logger.dart';
import 'package:ghotpromax/modules/impartus/services/client.dart';
import 'package:ghotpromax/providers/impartus.dart';
import 'package:ghotpromax/providers/preferences.dart';
import 'package:go_router/go_router.dart';

final _clientProvider = FutureProvider((ref) async {
  final prefs = ref.watch(preferencesProvider);
  final settings = ref.watch(impartusSettingsProvider);
  String? token = prefs.getString("impartus_token");

  if (token == null || !(await ImpartusClient.checkAuthToken(token))) {
    // fetch new token as stored one is invalid
    token = await ImpartusClient.getAuthToken(
      settings.email,
      settings.password,
    );
    logger.i("fetched a new impartus token cause the old one expired");

    await prefs.setString("impartus_token", token);
  }

  ref.read(impartusTokenProvider.notifier).state = token;
  return true;
});

class ImpartusAuthenticate extends ConsumerWidget {
  const ImpartusAuthenticate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(_clientProvider);
    return client.when(
      data: (_) => child,
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$error"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.go("/settings");
              },
              child: const Text("Go to Settings"),
            )
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
