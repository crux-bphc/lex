import 'package:flutter/material.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';
import 'package:lex/widgets/error_bird_container.dart';

/// A future builder with default loading and error widgets.
class ManagedFutureBuilder<T> extends StatelessWidget {
  const ManagedFutureBuilder({
    super.key,
    required this.future,
    required this.data,
    this.loading,
    this.error,
  }) : _isSliver = false;

  const ManagedFutureBuilder.sliver({
    super.key,
    required this.future,
    required this.data,
    this.loading,
    this.error,
  }) : _isSliver = true;

  final Future<T> future;

  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object? error)? error;

  final bool _isSliver;

  Widget _sliverify(Widget child) {
    if (_isSliver) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: child,
      );
    } else {
      return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return data(snapshot.requireData);
        }

        if (snapshot.hasError) {
          return error?.call(snapshot.error) ??
              _sliverify(ErrorBirdContainer(snapshot.error));
        }

        return loading?.call() ?? _sliverify(DelayedProgressIndicator());
      },
    );
  }
}
