import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/widgets/powered_by_crux.dart';
import 'package:signals/signals_flutter.dart';

/// Auth page shown while the app is starting up or when the user is not logged
/// in via Keycloak.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.sizeOf(context).width;
    double deviceHeight = MediaQuery.sizeOf(context).height;
    double scale = max(deviceWidth, deviceHeight);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -0.12 * scale,
            bottom: -0.12 * scale,
            width: scale * 0.4,
            height: scale * 0.4,
            child: Image.asset(
              "assets/landing.png",
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PoweredByCrux(
                  child: Text(
                    "LEX",
                    style: TextStyle(
                      fontSize: 120,
                      letterSpacing: 10,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // const Align(
                //   alignment: Alignment.centerRight,
                //   child: Text(
                //     "Powered by cruX",
                //     style: TextStyle(
                //       letterSpacing: 1,
                //     ),
                //   ),
                // ),
                Container(
                  height: 100,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: const Center(child: _AllReadyWidget()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllReadyWidget extends StatelessWidget {
  const _AllReadyWidget();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.instance.allReady(),
      builder: (context, snapshot) {
        final isReady = snapshot.connectionState == ConnectionState.done;

        // the check for auth is so that the user doesn't see the
        // login button if they are already logged
        // in (for the split second where the app
        // is transitioning)
        final isLoading = !isReady ||
            GetIt.instance<AuthProvider>().isLoggedIn.watch(context);

        return isLoading
            ? const SizedBox.square(
                dimension: 26,
                child: CircularProgressIndicator.adaptive(),
              )
            : OutlinedButton.icon(
                onPressed: () async {
                  // TODO: find exceptions that are thrown here
                  await GetIt.instance<AuthProvider>().login();
                },
                label: const Text('Login using Google'),
              );
      },
    );
  }
}