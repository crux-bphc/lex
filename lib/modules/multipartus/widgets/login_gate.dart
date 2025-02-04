import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/disclaimer_dialog.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:signals/signals_flutter.dart';

/// Displays [child] when the user is registered to Multipartus, otherwise
/// displays a login page.
class MultipartusLoginGate extends StatefulWidget {
  const MultipartusLoginGate({super.key, required this.child});

  final Widget child;

  @override
  State<MultipartusLoginGate> createState() => _MultipartusLoginGateState();
}

class _MultipartusLoginGateState extends State<MultipartusLoginGate> {
  Future<MultipartusRegistrationState> registrationState =
      GetIt.instance<MultipartusService>().fetchRegistrationState();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: registrationState,
      builder: (context, snapshot) {
        final registrationState = snapshot.data;

        return AnimatedSwitcher(
          duration: Durations.medium4,
          child: (registrationState) == MultipartusRegistrationState.registered
              ? widget.child
              : Center(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MultipartusTitle(),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: Center(
                            child: registrationState == null
                                ? Container()
                                : _Login(
                                    onLogin: handleLogin,
                                    showIncorrectPassword: registrationState ==
                                        MultipartusRegistrationState
                                            .invalidToken,
                                  )
                                    .animate()
                                    .fadeIn(duration: Durations.short3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<bool> handleLogin(String password) async {
    final result =
        await GetIt.instance<MultipartusService>().registerUser(password);
    if (result) {
      setState(
        () => registrationState =
            GetIt.instance<MultipartusService>().fetchRegistrationState(),
      );
    }
    return result;
  }
}

class _Login extends StatefulWidget {
  const _Login({
    required this.onLogin,
    required this.showIncorrectPassword,
  });

  // Returns true if the login was successful and false if not.
  final Future<bool> Function(String password) onLogin;
  final bool showIncorrectPassword;

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();

  final _isRegistering = signal(false);
  final _isTextEmpty = signal(true);
  late final _showIncorrectPassword = signal(widget.showIncorrectPassword);

  late final _didReadDisclaimer =
      GetIt.instance<LocalStorage>().preferences.isDisclaimerAccepted;

  late final _animationController = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      _isTextEmpty.value = _passwordController.text.isEmpty;
    });

    // don't bother subcribing
    if (_didReadDisclaimer.value) return;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_didReadDisclaimer.value) {
        showDisclaimerDialog();
      }
    });
  }

  void showDisclaimerDialog() async {
    _didReadDisclaimer.value = await showDialog(
      context: context,
      builder: (context) => const DisclaimerDialog(),
      barrierDismissible: false,
      useRootNavigator: false,
    );
  }

  void _handleSubmit(String text) async {
    _isRegistering.value = true;

    _showIncorrectPassword.value = !(await widget.onLogin(text));

    if (_showIncorrectPassword.value) {
      _passwordController.clear();
      _animationController.forward(from: 0);
      _focusNode.requestFocus();
    }

    _isRegistering.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Watch(
          (context) {
            final isIncorrect = _showIncorrectPassword();

            return TextField(
              controller: _passwordController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: "Impartus Password",
                error: isIncorrect ? SizedBox() : null,
                // used to center the text in the text field
                prefixIcon: isIncorrect ? SizedBox() : null,
                suffixIcon: isIncorrect
                    ? Tooltip(
                        message:
                            "Incorrect password. Please use your most updated Impartus password.",
                        waitDuration: Duration.zero,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        textStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                        ),
                        child: Icon(
                          LucideIcons.circle_alert,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                      )
                    : null,
              ),
              textAlign: TextAlign.center,
              obscureText: true,
              autofocus: false,
              onSubmitted: (text) {
                if (_didReadDisclaimer.value) {
                  _handleSubmit(text);
                }
              },
              onChanged: (_) => _showIncorrectPassword.value = false,
            )
                .animate(
                  controller: _animationController,
                  autoPlay: false,
                )
                .shakeX(duration: 500.ms, hz: 6, amount: 2);
          },
        ),
        SizedBox(height: 14),
        SizedBox(
          height: 36,
          width: 120,
          child: Watch(
            (context) => OutlinedButton(
              // enable button if the text field is not empty, the user has
              // read the disclaimer, and the user is not currently registering
              onPressed: !_isTextEmpty.value &&
                      _didReadDisclaimer.value &&
                      !_isRegistering()
                  ? () => _handleSubmit(_passwordController.text)
                  : null,
              child: _isRegistering()
                  ? const DelayedProgressIndicator(
                      duration: Duration(milliseconds: 100),
                      size: 20,
                    )
                  : const Text("LOGIN"),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _showIncorrectPassword.dispose();
    _animationController.dispose();
    _passwordController.dispose();
    _didReadDisclaimer.dispose();
    _isRegistering.dispose();
    _isTextEmpty.dispose();
    _focusNode.dispose();

    super.dispose();
  }
}
