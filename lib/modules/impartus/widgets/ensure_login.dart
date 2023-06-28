import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/providers/impartus.dart';
import 'package:ghotpromax/providers/preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final logger = Logger();

final _authTokenProvider = FutureProvider((ref) async {
  final prefs = ref.watch(preferencesProvider);
  final client = ref.watch(impartusClientProvider);
  String? token = prefs.getString("impartus_token");

  ref.listen(impartusClientProvider, (previous, next) async {
    await prefs.remove("impartus_token");
    logger.i("removed cached token");
  });

  if (token == null) {
    token = await client.getAuthToken();
    await prefs.setString("impartus_token", token);
    logger.i("fetched new token: $token");
  }

  client.setAuthToken(token);
  return token;
});

class ImpartusAuthenticate extends ConsumerWidget {
  const ImpartusAuthenticate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authToken = ref.watch(_authTokenProvider);
    return authToken.when(
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
