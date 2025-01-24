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

class DeferredValueMap<T, V> {
  final Map<T, (V?, Completer<V>)> _completers = {};

  void set(T key, V value) {
    final c = _completers.putIfAbsent(key, () => (value, Completer<V>())).$2;
    if (!c.isCompleted) {
      c.complete(value);
      _completers[key] = (value, c);
    }
  }

  V? maybeGet(T key) {
    return _completers[key]?.$1;
  }

  Future<V> get(T key, Function runner) async {
    final c = _completers[key]?.$1;
    if (c != null) return c;

    _completers[key] = (null, Completer());
    runner();

    return _completers[key]!.$2.future;
  }
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
