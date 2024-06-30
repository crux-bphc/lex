import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/auth/loading_page.dart';
import 'package:lex/providers/auth/auth_provider.dart';

class StartupAuthPage extends StatelessWidget {
  const StartupAuthPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance.allReady(),
      builder: (context, snapshot) {
        final ready = snapshot.connectionState == ConnectionState.done;

        return LoadingPage(
          // the check for auth is so that the user doesn't see the login button
          // if they are already logged in (for the split second where the app
          // is transitioning)
          showSignIn: ready && !GetIt.instance<AuthProvider>().isLoggedIn(),
        );
      },
    );
  }
}
