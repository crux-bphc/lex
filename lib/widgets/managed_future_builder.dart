import 'package:flutter/material.dart';
import 'package:lex/widgets/bird.dart';
import 'package:lex/widgets/delayed_progress_indicator.dart';

/// A future builder with default loading and error widgets.
class ManagedFutureBuilder<T> extends StatelessWidget {
  const ManagedFutureBuilder({
    super.key,
    required this.future,
    required this.data,
    this.loading,
    this.error,
  });

  final Future<T> future;

  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object? error)? error;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.hasError
              ? error?.call(snapshot.error) ??
                  ErrorBird(message: snapshot.error.toString())
              : data(snapshot.requireData);
        }

        return loading?.call() ?? DelayedProgressIndicator();
      },
    );
  }
}

class SliverManagedFutureBuilder<T> extends StatelessWidget {
  const SliverManagedFutureBuilder({
    super.key,
    required this.future,
    required this.data,
    this.loading,
    this.error,
  });

  final Future<T> future;

  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object? error)? error;

  @override
  Widget build(BuildContext context) {
    return ManagedFutureBuilder(
      future: future,
      data: data,
      loading: () =>
          loading?.call() ??
          SliverFillRemaining(
            hasScrollBody: false,
            child: DelayedProgressIndicator(),
          ),
      error: (e) =>
          error?.call(e) ??
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorBird(message: e.toString()),
          ),
    );
  }
}
