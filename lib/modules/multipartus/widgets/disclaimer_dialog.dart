import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lex/modules/multipartus/widgets/delayed_button.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

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
              DelayedButton(
                duration: const Duration(seconds: kDebugMode ? 0 : 3),
                buttonBuilder: (context, onPressed) => OutlinedButton(
                  onPressed: onPressed,
                  child: const Text("PROCEED"),
                ),
                onPressed: () => context.pop(true),
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
