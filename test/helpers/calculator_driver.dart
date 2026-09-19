import 'package:gate_calculator/calculator/domain/angle_mode.dart';
import 'package:gate_calculator/calculator/domain/calculator_action.dart';
import 'package:gate_calculator/calculator/domain/calculator_constant.dart';
import 'package:gate_calculator/calculator/domain/calculator_engine.dart';
import 'package:gate_calculator/calculator/domain/calculator_error.dart';
import 'package:gate_calculator/calculator/domain/calculator_function.dart';
import 'package:gate_calculator/calculator/domain/calculator_operation.dart';
import 'package:gate_calculator/calculator/domain/calculator_state.dart';

/// Drives [CalculatorEngine] with button sequences so tests can be written the
/// same way the reference documentation describes them:
/// `60 -> + -> 35 -> * -> 5 -> =`.
class CalculatorDriver {
  CalculatorDriver({AngleMode mode = AngleMode.degree})
      : _state = CalculatorState(angleMode: mode);

  static const CalculatorEngine _engine = CalculatorEngine();

  CalculatorState _state;

  CalculatorState get state => _state;

  /// Expression (key sequence) display.
  String get expression => _state.expressionText;

  /// Result / input display.
  String get result => _state.resultText;

  /// Result display parsed as a number (fails loudly if it is `Error`).
  double get value => double.parse(result);

  bool get hasError => _state.isError;

  CalculatorError? get error => _state.error;

  CalculatorDriver press(CalculatorAction action) {
    _state = _engine.process(action, _state);
    return this;
  }

  CalculatorDriver pressAll(Iterable<CalculatorAction> actions) {
    for (final CalculatorAction action in actions) {
      press(action);
    }
    return this;
  }

  /// Types a literal such as `1.23` digit by digit.
  CalculatorDriver numbers(String literal) {
    for (final int rune in literal.runes) {
      final String character = String.fromCharCode(rune);
      if (character == '.') {
        press(CalculatorAction.decimalPoint());
      } else {
        press(CalculatorAction.number(int.parse(character)));
      }
    }
    return this;
  }

  CalculatorDriver operator(CalculatorOperation operation) =>
      press(CalculatorAction.operator(operation));

  CalculatorDriver function(CalculatorFunction function) =>
      press(CalculatorAction.function(function));

  CalculatorDriver constant(CalculatorConstant constant) =>
      press(CalculatorAction.constant(constant));

  CalculatorDriver memory(MemoryOperation operation) =>
      press(CalculatorAction.memory(operation));

  CalculatorDriver angleMode(AngleMode mode) =>
      press(CalculatorAction.angleMode(mode));

  // Postfix key helpers so the sequences read like the keypad.
  CalculatorDriver add() => operator(CalculatorOperation.add);
  CalculatorDriver subtract() => operator(CalculatorOperation.subtract);
  CalculatorDriver multiply() => operator(CalculatorOperation.multiply);
  CalculatorDriver divide() => operator(CalculatorOperation.divide);
  CalculatorDriver modulo() => operator(CalculatorOperation.modulo);
  CalculatorDriver power() => operator(CalculatorOperation.power);
  CalculatorDriver yRoot() => operator(CalculatorOperation.yRoot);
  CalculatorDriver logBase() => operator(CalculatorOperation.logBase);
  CalculatorDriver expKey() => operator(CalculatorOperation.exponentEntry);

  CalculatorDriver open() => press(const CalculatorAction.openParenthesis());
  CalculatorDriver close() => press(const CalculatorAction.closeParenthesis());
  CalculatorDriver equals() => press(CalculatorAction.equals);
  CalculatorDriver decimal() => press(CalculatorAction.decimalPoint());
  CalculatorDriver clear() => press(CalculatorAction.clear);
  CalculatorDriver backspace() => press(CalculatorAction.backspace);
  CalculatorDriver signChange() => press(CalculatorAction.signChange);
}