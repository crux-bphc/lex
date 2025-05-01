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
      final works = bruh(state);
      return works;
    }

    return false;
  }

  bool bruh(HardwareKeyboard state) {
    return !(state.isShiftPressed ^ shift) &&
        !state.isAltPressed &&
        !state.isMetaPressed &&
        !state.isControlPressed;
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
