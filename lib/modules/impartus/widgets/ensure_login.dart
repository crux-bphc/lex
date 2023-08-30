import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lex/utils/logger.dart';
import 'package:lex/modules/impartus/services/client.dart';
import 'package:lex/providers/impartus.dart';
import 'package:go_router/go_router.dart';

final _clientProvider = FutureProvider((ref) async {
  final settings = ref.watch(impartusSettingsProvider);
  String token = ref.watch(impartusTokenProvider);

  if (token.isEmpty || !(await ImpartusClient.checkAuthToken(token))) {
    // fetch new token as stored one is invalid
    token = await ImpartusClient.getAuthToken(
      settings.email,
      settings.password,
    );
    logger.i("fetched a new impartus token cause the old one expired");
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
            ),
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
