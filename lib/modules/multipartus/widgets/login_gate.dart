import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/disclaimer_dialog.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
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
        GetIt.instance<MultipartusService>().registrationState.watch(context);

    return AnimatedSwitcher(
      duration: Durations.medium2,
      child: isRegistered.map(
        data: (registered) =>
            registered == MultipartusRegistrationState.registered
                ? child
                : Center(
                    child: SizedBox(
                      width: 500,
                      child: _Login(
                        onLogin: handleLogin,
                        isPasswordIncorrect: registered ==
                            MultipartusRegistrationState.invalidToken,
                      ),
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
  const _Login({required this.onLogin, required this.isPasswordIncorrect});

  final void Function(String password) onLogin;
  final bool isPasswordIncorrect;

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  late final _didReadDisclaimer =
      GetIt.instance<LocalStorage>().preferences.isDisclaimerAccepted;

  void showDisclaimerDialog() async {
    _didReadDisclaimer.value = await showDialog(
      context: context,
      builder: (context) => const DisclaimerDialog(),
      barrierDismissible: false,
      useRootNavigator: false,
    );
  }

  @override
  void initState() {
    super.initState();

    // don't bother subcribing
    if (_didReadDisclaimer.value) return;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_didReadDisclaimer.value) {
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
        SizedBox(
          height: 60,
          child: Align(
            alignment: Alignment.topCenter,
            child: TextField(
              controller: _passwordController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: "Impartus Password",
                errorText: widget.isPasswordIncorrect
                    ? "Incorrect password. Please use your most updated Impartus password."
                    : null,
              ),
              textAlign: TextAlign.center,
              obscureText: true,
              autofocus: false,
              onSubmitted: (text) {
                if (_didReadDisclaimer.value) {
                  widget.onLogin(text);
                }
              },
            )
                .animate(target: widget.isPasswordIncorrect ? 1 : 0)
                .shakeX(duration: 500.ms, hz: 6, amount: 2),
          ),
        ),
        const SizedBox(height: 8),
        Watch(
          (context) => OutlinedButton(
            onPressed: _didReadDisclaimer.value
                ? () => widget.onLogin(_passwordController.text)
                : null,
            child: const Text("LOGIN"),
          ),
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
