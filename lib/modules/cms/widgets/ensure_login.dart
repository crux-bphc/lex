import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghotpromax/providers/cms.dart';
import 'package:go_router/go_router.dart';

class CMSAuthenticate extends ConsumerWidget {
  const CMSAuthenticate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(cmsUser);
    return user.when(
      data: (_) => child,
      error: (error, stacktrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Oops",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              "Seems your login is invalid, try to enter credentials again.",
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.settings,
                size: 20,
              ),
              onPressed: () {
                context.go("/settings");
              },
              label: const Text("Go to Settings"),
            ),
            const SizedBox(height: 12),
            Text(
              "$error\n$stacktrace",
              style: Theme.of(context).textTheme.bodySmall,
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
