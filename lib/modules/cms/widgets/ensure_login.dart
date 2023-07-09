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
