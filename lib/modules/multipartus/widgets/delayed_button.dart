import 'package:flutter/material.dart';

class DelayedButton extends StatefulWidget {
  const DelayedButton({
    super.key,
    required this.buttonBuilder,
    required this.duration,
    this.onPressed,
  });

  final Widget Function(BuildContext context, void Function()? onPressed)
      buttonBuilder;
  final void Function()? onPressed;
  final Duration duration;

  @override
  State<DelayedButton> createState() => _DelayedButtonState();
}

class _DelayedButtonState extends State<DelayedButton> {
  late final _future = Future.delayed(widget.duration);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) => widget.buttonBuilder(
        context,
        snapshot.connectionState == ConnectionState.done
            ? widget.onPressed
            : null,
      ),
    );
  }
}
