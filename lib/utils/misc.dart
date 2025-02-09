import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat.yMMMd().add_jm();
final _timeFormat = DateFormat.jm();

String formatDate(DateTime dt) {
  if (DateTime.now().difference(dt).inDays < 1) {
    return "Today ${_timeFormat.format(dt)}";
  }
  return _dateFormat.format(dt);
}

void Function(T arg, {bool now}) debouncer<T>(
  void Function(T args) fn, {
  required Duration duration,
}) {
  Timer? timer;
  return (T arg, {bool now = false}) {
    timer?.cancel();
    if (now) {
      fn(arg);
    } else {
      timer = Timer(duration, () => fn(arg));
    }
  };
}

class CurvedRectTween extends Tween<Rect> {
  CurvedRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  static const Curve _curve = Curves.easeOutQuad;

  @override
  Rect lerp(double t) {
    return Rect.lerp(
      begin,
      end,
      _curve.transform(t),
    )!;
  }
}

class AsyncCached<I, O> {
  final Future<O> Function(I) compute;

  final _cache = <I, Future<O>>{};

  AsyncCached(this.compute);

  Future<O> call(I input) {
    return _cache.putIfAbsent(input, () => compute(input));
  }
}
