import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/widgets/delayed_button.dart';

class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({super.key});

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: SizedBox(
          child: AlertDialog(
            title: const Text("DISCLAIMER"),
            content: SizedBox(
              width: 350,
              child: Text(
                _disclaimerText,
                style: Theme.of(context).dialogTheme.contentTextStyle,
                softWrap: true,
              ),
            ),
            actions: [
              _DelayedProgressBarButton(
                duration: const Duration(seconds: 3),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("PROCEED"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _disclaimerText =
    """Multipartus uses and stores your actual Impartus password with encryption.

If your Impartus password is common for other platforms, this is an advisory notice to change your Impartus password before logging in.""";

class _DelayedProgressBarButton extends StatefulWidget {
  const _DelayedProgressBarButton({
    required this.duration,
    required this.child,
    required this.onPressed,
  });

  final Duration duration;
  final Widget child;
  final void Function() onPressed;

  @override
  State<_DelayedProgressBarButton> createState() =>
      _DelayedProgressBarButtonState();
}

class _DelayedProgressBarButtonState extends State<_DelayedProgressBarButton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 0,
  )..forward();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DelayedButton(
          duration: widget.duration,
          onPressed: widget.onPressed,
          buttonBuilder: (context, onPressed) => OutlinedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 36,
              width: 120,
              child: Stack(
                children: [
                  AnimatedOpacity(
                    opacity:
                        _controller.status == AnimationStatus.completed ? 0 : 1,
                    duration: Durations.short2,
                    child: SizedBox(
                      height: double.infinity,
                      child: LinearProgressIndicator(
                        value: _controller.value,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white12
                                : Colors.black12,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
