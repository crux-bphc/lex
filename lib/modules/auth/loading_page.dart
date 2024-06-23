import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/providers/auth/auth_provider.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,
    required this.showSignIn,
  });

  final bool showSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "LEX",
                style: TextStyle(
                  fontSize: 120,
                  letterSpacing: 10,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Powered by cruX",
                  style: TextStyle(
                    letterSpacing: 1,
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
      ),
    );
  }
}
