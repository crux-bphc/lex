import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyEventShortcutActivator<T> extends ShortcutActivator {
  final LogicalKeyboardKey trigger;
  final bool shift;

  KeyEventShortcutActivator(
    this.trigger, {
    this.shift = false,
  });

  @override
  bool accepts(KeyEvent event, HardwareKeyboard state) {
    if (event is! T) return false;

    if (event.logicalKey == trigger) {
      return state.isShiftPressed || !shift;
    }
    return event.logicalKey == trigger;
  }

  @override
  String debugDescribeKeys() {
    final result = [
      if (shift) 'Shift',
      trigger.debugName ?? trigger.toStringShort(),
    ];
    return result.join(' + ');
  }
}
