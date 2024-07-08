import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/disclaimer_dialog.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:signals/signals_flutter.dart';

/// Displays [child] when the user is registered to Multipartus, otherwise
/// displays a login page.
class MultipartusLoginGate extends StatelessWidget {
  const MultipartusLoginGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRegistered =
        GetIt.instance<MultipartusService>().isRegistered.watch(context);

    return isRegistered.map(
      data: (registered) => registered
          ? child
          : Center(
              child: SizedBox(
                width: 450,
                child: _Login(onLogin: handleLogin),
              ),
            ),
      error: (e, _) => Text("error: $e"),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  void handleLogin(String password) async {
    await GetIt.instance<MultipartusService>().registerUser(password);
  }
}

class _Login extends StatefulWidget {
  const _Login({required this.onLogin});

  final void Function(String password) onLogin;

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final passwordController = TextEditingController();
  bool didReadDisclaimer = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MultipartusTitle(),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(hintText: "Impartus Password"),
          textAlign: TextAlign.center,
          obscureText: true,
          autofocus: false,
          onTap: () async {
            if (!didReadDisclaimer) {
              final result = await showDialog(
                context: context,
                builder: (context) => const DisclaimerDialog(),
                barrierDismissible: false,
              );
              setState(() {
                didReadDisclaimer = result;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: didReadDisclaimer
              ? () => widget.onLogin(passwordController.text)
              : null,
          child: const Text("Login"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
