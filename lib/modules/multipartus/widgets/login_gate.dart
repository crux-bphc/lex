import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/disclaimer_dialog.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
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

    return AnimatedSwitcher(
      duration: 300.ms,
      child: isRegistered.map(
        data: (registered) => registered
            ? child
            : Center(
                child: SizedBox(
                  width: 500,
                  child: _Login(onLogin: handleLogin),
                ),
              ),
        error: (e, _) => Text("error: $e"),
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MultipartusTitle(),
              SizedBox(height: 30),
              DelayedProgressIndicator(),
            ],
          ),
        ),
      ),
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
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  bool _didReadDisclaimer = false;

  void showDisclaimerDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const DisclaimerDialog(),
      barrierDismissible: false,
      useRootNavigator: false,
    );
    setState(() {
      _didReadDisclaimer = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_didReadDisclaimer) {
        showDisclaimerDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MultipartusTitle(),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          focusNode: _focusNode,
          decoration: const InputDecoration(hintText: "Impartus Password"),
          textAlign: TextAlign.center,
          obscureText: true,
          autofocus: false,
          onSubmitted: (text) {
            if (_didReadDisclaimer) {
              widget.onLogin(text);
            }
          },
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: _didReadDisclaimer
              ? () => widget.onLogin(_passwordController.text)
              : null,
          child: const Text("LOGIN"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
