import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lex/modules/multipartus/widgets/delayed_button.dart';

class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({super.key});

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> colorAnimation; 

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: kDebugMode ? 0 : 3),
    )..addListener(() {
        setState(() {});
      });
    colorAnimation = controller.drive(ColorTween(
      begin: Colors.grey,
      end: Colors.transparent,
    ));
    // colorAnimation = AlwaysStoppedAnimation<Color>(Colors.grey);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
                  child: Stack(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                        child: LinearProgressIndicator(
                          value: controller.value,
                          backgroundColor: Colors.transparent,
                          valueColor: colorAnimation,
                        ),
                      ),
                      Align(child: Text("PROCEED"), alignment: Alignment.topCenter),
                    ],
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
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
