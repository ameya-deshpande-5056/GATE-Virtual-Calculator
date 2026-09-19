import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/calculator_action.dart';
import '../../domain/calculator_operation.dart';
import '../../domain/calculator_function.dart';

/// Physical keyboard support for the web/desktop builds.
///
/// Keyboard input dispatches exactly the same [CalculatorAction] objects as the
/// touch keys - there is no separate keyboard calculation path.
class CalculatorKeyboard extends StatelessWidget {
  const CalculatorKeyboard({required this.onAction, required this.child, super.key});

  final void Function(CalculatorAction action) onAction;
  final Widget child;

  static final Map<LogicalKeyboardKey, CalculatorAction?> _simple =
      <LogicalKeyboardKey, CalculatorAction?>{
    LogicalKeyboardKey.digit0: CalculatorAction.number(0),
    LogicalKeyboardKey.digit1: CalculatorAction.number(1),
    LogicalKeyboardKey.digit2: CalculatorAction.number(2),
    LogicalKeyboardKey.digit3: CalculatorAction.number(3),
    LogicalKeyboardKey.digit4: CalculatorAction.number(4),
    LogicalKeyboardKey.digit5: CalculatorAction.number(5),
    LogicalKeyboardKey.digit6: CalculatorAction.number(6),
    LogicalKeyboardKey.digit7: CalculatorAction.number(7),
    LogicalKeyboardKey.digit8: CalculatorAction.number(8),
    LogicalKeyboardKey.digit9: CalculatorAction.number(9),
    LogicalKeyboardKey.numpad0: CalculatorAction.number(0),
    LogicalKeyboardKey.numpad1: CalculatorAction.number(1),
    LogicalKeyboardKey.numpad2: CalculatorAction.number(2),
    LogicalKeyboardKey.numpad3: CalculatorAction.number(3),
    LogicalKeyboardKey.numpad4: CalculatorAction.number(4),
    LogicalKeyboardKey.numpad5: CalculatorAction.number(5),
    LogicalKeyboardKey.numpad6: CalculatorAction.number(6),
    LogicalKeyboardKey.numpad7: CalculatorAction.number(7),
    LogicalKeyboardKey.numpad8: CalculatorAction.number(8),
    LogicalKeyboardKey.numpad9: CalculatorAction.number(9),
    LogicalKeyboardKey.numpadAdd: CalculatorAction.operator(CalculatorOperation.add),
    LogicalKeyboardKey.numpadSubtract:
        CalculatorAction.operator(CalculatorOperation.subtract),
    LogicalKeyboardKey.numpadMultiply:
        CalculatorAction.operator(CalculatorOperation.multiply),
    LogicalKeyboardKey.numpadDivide:
        CalculatorAction.operator(CalculatorOperation.divide),
    LogicalKeyboardKey.numpadDecimal: const CalculatorAction.decimalPoint(),
    LogicalKeyboardKey.numpadEnter: CalculatorAction.equals,
    LogicalKeyboardKey.enter: CalculatorAction.equals,
    LogicalKeyboardKey.equal: CalculatorAction.equals,
    LogicalKeyboardKey.backspace: CalculatorAction.backspace,
    LogicalKeyboardKey.escape: CalculatorAction.clear,
    LogicalKeyboardKey.delete: CalculatorAction.clear,
    LogicalKeyboardKey.minus: CalculatorAction.operator(CalculatorOperation.subtract),
    LogicalKeyboardKey.asterisk: CalculatorAction.operator(CalculatorOperation.multiply),
    LogicalKeyboardKey.slash: CalculatorAction.operator(CalculatorOperation.divide),
    LogicalKeyboardKey.period: const CalculatorAction.decimalPoint(),
    LogicalKeyboardKey.comma: const CalculatorAction.decimalPoint(),
    LogicalKeyboardKey.caret: CalculatorAction.operator(CalculatorOperation.power),
    LogicalKeyboardKey.percent: CalculatorAction.function(CalculatorFunction.percent),
    LogicalKeyboardKey.exclamation: CalculatorAction.function(CalculatorFunction.factorial),
  };

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        final bool shift = HardwareKeyboard.instance.isShiftPressed;
        final CalculatorAction? action = _map(event.logicalKey, shift);
        if (action == null) {
          return KeyEventResult.ignored;
        }
        onAction(action);
        return KeyEventResult.handled;
      },
      child: child,
    );
  }

  /// Shift turns `8`/`9` into `*`/`(` and `=` into `+` on most layouts.
  static CalculatorAction? _map(LogicalKeyboardKey key, bool shift) {
    if (!shift) {
      return _simple[key];
    }
    if (key == LogicalKeyboardKey.digit9) {
      return const CalculatorAction.openParenthesis();
    }
    if (key == LogicalKeyboardKey.digit0) {
      return const CalculatorAction.closeParenthesis();
    }
    if (key == LogicalKeyboardKey.digit8) {
      return CalculatorAction.operator(CalculatorOperation.multiply);
    }
    if (key == LogicalKeyboardKey.equal) {
      return CalculatorAction.operator(CalculatorOperation.add);
    }
    return null;
  }
}
