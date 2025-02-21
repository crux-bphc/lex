import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get_it/get_it.dart';
import 'package:lex/modules/multipartus/service.dart';
import 'package:lex/modules/multipartus/widgets/disclaimer_dialog.dart';
import 'package:lex/modules/multipartus/widgets/multipartus_title.dart';
import 'package:lex/providers/local_storage/local_storage.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:lex/widgets/error_bird_container.dart';
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

  Future<(bool, String)> handleLogin(String password) async {
    final service = GetIt.instance<MultipartusService>();

    final result = await service.registerUser(password);

    if (result.$1) {
      setState(() {
        registrationState = service.fetchRegistrationState();
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: registrationState,
      builder: (context, snapshot) {
        final registrationState = snapshot.data;
        final error = snapshot.error;

        return AnimatedSwitcher(
          duration: Durations.medium4,
          child: (registrationState) == MultipartusRegistrationState.registered
              ? widget.child
              : Center(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MultipartusTitle(
                          isMultiline: true,
                          fontSize: 60,
                        ),
                        SizedBox(height: 16),
                        _buildSub(
                          registrationState: registrationState,
                          error: error,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSub({
    MultipartusRegistrationState? registrationState,
    Object? error,
  }) {
    if (error != null) {
      return SizedBox(
        height: 200,
        child: ErrorBirdContainer(error),
      );
    }
    return SizedBox(
      height: 120,
      child: registrationState == null
          ? Container()
          : _Login(
              onLogin: handleLogin,
              showIncorrectPassword: registrationState ==
                  MultipartusRegistrationState.invalidToken,
            ).animate().fadeIn(duration: Durations.short3),
    );
  }
}

class _Login extends StatefulWidget {
  const _Login({
    required this.onLogin,
    required this.showIncorrectPassword,
  });

  // Returns true if the login was successful and false if not.
  final Future<(bool, String)> Function(String password) onLogin;
  final bool showIncorrectPassword;

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();

  final _isRegistering = signal(false);
  final _isTextEmpty = signal(true);
  final _hidePassword = signal(true);
  final _backendError = signal<String?>(null);
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

    // wow look its go
    final (result, err) = await widget.onLogin(text);

    _showIncorrectPassword.value = !result;
    if (!result) {
      _backendError.value = err;
    }

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
                errorText: isIncorrect
                    ? "Incorrect password. Please use your most updated Impartus password."
                    : null,
                // used to center the text in the text field
                suffixIcon: IconButton(
                  onPressed: () => _hidePassword.value = !_hidePassword.value,
                  icon: Icon(LucideIcons.eye),
                ),
                prefixIcon: Visibility(
                  visible: isIncorrect && _backendError() != null,
                  child: Tooltip(
                    message: _backendError() ?? '',
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
                  ),
                ),
              ),
              textAlign: TextAlign.center,
              obscureText: _hidePassword(),
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
                // shake when the password is incorrect
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
