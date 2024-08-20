import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';
import 'package:lex/widgets/powered_by_crux.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,
    required this.showSignIn,
  });

  final bool showSignIn;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.sizeOf(context).width;
    double deviceHeight = MediaQuery.sizeOf(context).height;
    double scale = max(deviceWidth, deviceHeight);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
                "assets/landing.png",
            ),
            left: -0.12 * scale,
            bottom: -0.12 * scale,
            width: scale * 0.4,
            height: scale * 0.4,
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
                Container(
                  height: 100,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: showSignIn
                        ? OutlinedButton.icon(
                      onPressed: () async {
                        // TODO: find exceptions that are thrown here
                        await GetIt.instance<AuthProvider>().login();
                      },
                      label: const Text('Login using Google'),
                    )
                        : const SizedBox.square(
                      dimension: 26,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
